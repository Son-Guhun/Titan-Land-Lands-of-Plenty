library SaveUnit requires SaveNLoad, SaveIO, Maths, SaveNLoadProgressBars, optional SaveUnitExtras /*

// Libraries whose values are serialized when saving:
*/ UnitVisualValues, DecorationSFX, AttachedSFX
/* 



SaveUnitExtras library:
    If this library exists, it must define the following function:
    
    function SaveUnitExtraStrings takes SaveWriter saveWriter, unit saveUnit, integer unitHandleId returns nothing
    
    This function is executed after a unit's save string is saved, and is intended to save extra information.
    In LoP, this extra information includes waygate destinations, patrol points and rects.
*/
globals
    
    // Non-rect saves in which all units are contained within a rect smaller than these extents will
    // be automatically converted to a rect save.
    public constant real MAX_X_EXTENT = 10000
    public constant real MAX_Y_EXTENT = MAX_X_EXTENT
    
    // The number of units to be saved with each call to SaveInstanceUnit.saveNextUnits()
    public constant integer BATCH_SIZE = 25
    
endglobals

// Used by GenerateEffectFlagsStr and GenerateFlagsStr
private function I2FlagsString takes integer flags returns string
    return I2S(flags)  // TODO: If max flag exceeds 4, we need to use AnyBase(92) instead of I2S
endfunction

scope SFX
    /*
        Utility functions to serialize SpecialEffects into strings.
    */

    private function GetFacingString takes SpecialEffect sfx returns string
        if sfx.roll == 0 and sfx.pitch == 0 then
            return R2S(sfx.yaw*bj_RADTODEG)
        else
            return R2S(sfx.yaw*128) + "|" + R2S(sfx.pitch*128) + "|" + R2S(sfx.roll*128)
        endif
    endfunction

    private function GetScaleString takes SpecialEffect sfx returns string
        local real scaleX = sfx.scaleX
        if sfx.scaleY != scaleX  or sfx.scaleZ != scaleX then
            return R2S(sfx.scaleX) + "|" + R2S(sfx.scaleY) + "|" + R2S(sfx.scaleZ)
        else
            return R2S(sfx.scaleX)
        endif
    endfunction

    public function GetFlagsStr takes SpecialEffect sfx returns string
        local integer result = 0
        
        if not ObjectPathing(sfx).isDisabled then
            set result = result + SaveNLoad_BoolFlags.UNROOTED
        endif

        return I2FlagsString(result)
    endfunction


    public function GetSaveStr takes SpecialEffect whichEffect, player owner, boolean hasCustomColor, integer selectionType returns string
        local string animTags
        local string color
        local SaveNLoad_PlayerData playerId = GetPlayerId(owner)
        
        if hasCustomColor then
            set color = I2S(whichEffect.color + 1)
        else
            set color = "D"
        endif
        
        if whichEffect.hasSubAnimations() then
            set animTags = SaveIO_CleanUpString(GUMSConvertTags(UnitVisualMods_TAGS_COMPRESS, SubAnimations2Tags(whichEffect.subanimations)))
        else
            set animTags = "D"
        endif

        return ID2S(whichEffect.unitType) + "," +/*
            */ R2S(whichEffect.x) + "," +/*
            */ R2S(whichEffect.y) + "," +/*
            */ R2S(whichEffect.height) + "," +/*
            */ GetFacingString(whichEffect) + "," +/*
            */ GetScaleString(whichEffect) + "," +/*
            */ I2S(whichEffect.red) + "," +/*
            */ I2S(whichEffect.green) + "," +/*
            */ I2S(whichEffect.blue) + "," +/*
            */ I2S(whichEffect.alpha) + "," +/*
            */ color + "," +/*
            */ R2S(whichEffect.animationSpeed) + "," +/*
            */ animTags + "," +/*
            */ I2S(selectionType)
    endfunction

endscope

scope Unit
    /*
        Utility functions to serialize units into strings.
    */

    public function GetFlagsStr takes unit saveUnit returns string
        local integer result = 0
        
        if LoP_IsUnitDecoration(saveUnit) and not ObjectPathing.get(saveUnit).isDisabled then
            set result = result + SaveNLoad_BoolFlags.UNROOTED
            
        elseif IsUnitType(saveUnit, UNIT_TYPE_ANCIENT) and BlzGetUnitIntegerField(saveUnit, UNIT_IF_DEFENSE_TYPE) == GetHandleId(DEFENSE_TYPE_LARGE) then
            set result = result + SaveNLoad_BoolFlags.UNROOTED
            
        endif
        if GetOwningPlayer(saveUnit) == Player(PLAYER_NEUTRAL_PASSIVE) then
            set result = result + SaveNLoad_BoolFlags.NEUTRAL
            
        endif
        
        return I2FlagsString(result)
    endfunction

endscope

struct SaveInstanceUnit extends array

    implement ExtendsTable
    implement SaveInstanceBaseModule
    
    //! runtextmacro HashStruct_NewHandleField("units", "group")
    //! runtextmacro HashStruct_NewStructField("effects", "LinkedHashSet")
    
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("savedCount", "integer")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("total", "integer")

    // Extents. These are used only if the SaveWriter is not a rect save.
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("minX", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("minY", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("maxX", "real")
    //! runtextmacro HashStruct_NewReadonlyPrimitiveField("maxY", "real")
    
    method initialize takes nothing returns nothing
        set .savedCount = 0
        set .total = 0
    
        set .maxX = -Pow(2, 23)
        set .minX = Pow(2, 23)
        set .maxY = -Pow(2, 23)
        set .minY = Pow(2, 23)
        
        if User.Local == saveWriter.player then
            call BlzFrameSetText(saveProgressBarText, "Waiting...")
            call BlzFrameSetVisible(saveProgressBar, true)
            call BlzFrameSetValue(saveProgressBar, 0.)
        endif
    endmethod


    // Calculate the extents for a Rect save.
    private method calculateRectSave takes nothing returns nothing
        local SaveWriter saveWriter = .saveWriter
        local real extentX = (.maxX - .minX)/2
        local real extentY = (.maxY - .minY)/2
        
        local real centerX = .maxX - extentX
        local real centerY = .maxY - extentY
        
        local real offsetX = GetTileCenterCoordinate(centerX) - centerX
        local real offsetY = GetTileCenterCoordinate(centerY) - centerY
        
        set centerX = centerX + offsetX
        set centerY = centerY + offsetY
        set extentX = extentX + RAbsBJ(offsetX)
        set extentY = extentY + RAbsBJ(offsetY)
        
        set extentX = Math.ceil(extentX)
        set extentY = Math.ceil(extentY)
        
        if ModuloReal(extentX, 64) != 32 then
            set extentX = 64*R2I(extentX/64) + 96
        endif
        if ModuloReal(extentY, 64) != 32 then
            set extentY = 64*R2I(extentY/64) + 96
        endif
        
        if extentX < 10000 and extentY < 10000 then
            set saveWriter.centerX = centerX
            set saveWriter.centerY = centerY
            set saveWriter.extentX = extentX
            set saveWriter.extentY = extentY
        endif
    endmethod
    
    // Update the extents, if the point is outside the current extents.
    private method updateExtents takes real x, real y returns nothing
        if x > .maxX then
            set .maxX = x
        endif
        if x < .minX then
            set .minX = x
        endif
        if y > .maxY then
            set .maxY = y
        endif
        if y < .minY then
            set .minY = y
        endif    
    endmethod

    
    method saveNextEffects takes nothing returns integer
        local SaveWriter saveWriter = .saveWriter
        local LinkedHashSet_DecorationEffect decorations = .effects
        local DecorationEffect decoration = decorations.begin()

        local integer counter = 0
        local string saveStr
        
        loop
            exitwhen counter == BATCH_SIZE or decoration == decorations.end()
            
            call saveWriter.write(SaveNLoad_FormatString("SnL_unit", SFX_GetSaveStr(decoration, decoration.getOwner(), decoration.hasCustomColor, GUMS_SELECTION_UNSELECTABLE()) + "," + SFX_GetFlagsStr(decoration)))
            
            if not saveWriter.isRectSave() then
                call .updateExtents(decoration.x, decoration.y)
            endif
            
            set decoration = decorations.next(decoration)
            call decorations.remove(decorations.prev(decoration))

            set counter = counter + 1
        endloop
        
        return counter
    endmethod
    
    method isFinished takes nothing returns boolean
        return not ((.units_exists() and not IsGroupEmpty(.units)) or (.effects_exists() and not .effects.isEmpty()))
    endmethod


    method saveNextUnits takes nothing returns boolean
        local SaveWriter saveWriter = .saveWriter
        local player filterPlayer = saveWriter.player
        local integer playerId = GetPlayerId(filterPlayer)
        local unit saveUnit
        local integer saveUnitCount = 0
        local string saveStr
        local UnitVisuals unitHandleId
        
        local group grp
        
        if .savedCount == 0 then
            set .total = BlzGroupGetSize(.units) + .effects.size()  // count total here to avoid OP limit
        endif
        
        set saveUnitCount = .saveNextEffects()  // Only begin saving units once all decorations have been saved.
        loop
        exitwhen saveUnitCount >= BATCH_SIZE
            set grp = .units
            set saveUnit = FirstOfGroup(grp)
            set unitHandleId = GetHandleId(saveUnit)
            call GroupRemoveUnit(grp, saveUnit)

            //Check if Unit has been removed
            if saveUnit == null then
                // Removed unit
                if not IsGroupEmpty(grp) then
                    call GroupRefresh(grp)
                endif
            elseif (IsUnitHidden(saveUnit) and not IsUnitLoaded(saveUnit)) or not UnitAlive(saveUnit) then
                // Don't save dead and hidden units
            else
                if UnitHasAttachedEffect(saveUnit) then
                    set saveStr = SFX_GetSaveStr(GetUnitAttachedEffect(saveUnit), filterPlayer, unitHandleId.hasColor(), GUMS_GetUnitSelectionType(saveUnit))+","+Unit_GetFlagsStr(saveUnit)
                else
                    set saveStr = ID2S((GetUnitTypeId(saveUnit))) + "," + /*
                                */   R2S(GetUnitX(saveUnit))+","+  /*
                                */   R2S(GetUnitY(saveUnit)) + "," + /*
                                */   R2S(GetUnitFlyHeight(saveUnit)) + "," + /*
                                */   R2S(GetUnitFacing(saveUnit)) + "," + /*
                                */   unitHandleId.getScale() + "," + /*
                                */   unitHandleId.getVertexRed() + "," + /*
                                */   unitHandleId.getVertexGreen() + "," + /*
                                */   unitHandleId.getVertexBlue() + "," + /*
                                */   unitHandleId.getVertexAlpha() + "," + /*
                                */   unitHandleId.getColor() + "," + /*
                                */   unitHandleId.getAnimSpeed() + "," + /*
                                */   SaveIO_CleanUpString(unitHandleId.getAnimTag()) + "," + /*
                                */   I2S(GUMS_GetUnitSelectionType(saveUnit)) + "," + /*
                                */   Unit_GetFlagsStr(saveUnit)
                endif
                
                call saveWriter.write(SaveNLoad_FormatString("SnL_unit", saveStr))
                
                if not saveWriter.isRectSave() then
                    call .updateExtents(GetUnitX(saveUnit), GetUnitY(saveUnit))
                endif
                
                if GUMSUnitHasCustomName(unitHandleId) then
                    call saveWriter.write(SaveNLoad_FormatString("SnL_unit_extra", "=n " + SaveIO_CleanUpString(GUMSGetUnitName(saveUnit))))
                endif
                
                static if LIBRARY_SaveUnitExtras then
                    call SaveUnitExtraStrings(saveWriter, saveUnit, unitHandleId)
                endif
            endif
                
            //This block should be below the group refresh check in order to always produce correct results
            if IsGroupEmpty(grp) then
                call DisplayTextToPlayer(filterPlayer,0,0, "Finished Saving" )
                exitwhen true
            endif
                
            set saveUnitCount = saveUnitCount +1
        endloop
        
        //This if statement must remain inside (if playerId.isSaving == true) statement to avoid output for people who aren't saving
        if IsGroupEmpty(grp) and .effects.isEmpty() then
            if not saveWriter.isRectSave() then
                call .calculateRectSave()
            endif
        else
            set .savedCount = .savedCount + 1
            if User.fromLocal() == playerId then
                call BlzFrameSetText(saveProgressBarText, I2S(.savedCount*BATCH_SIZE)+ "/" +I2S(.total))
                call BlzFrameSetValue(saveProgressBar, 100.*.savedCount*BATCH_SIZE / I2R(.total))
            endif
        endif
        
        set saveUnit = null
        return false
    endmethod
endstruct

endlibrary
