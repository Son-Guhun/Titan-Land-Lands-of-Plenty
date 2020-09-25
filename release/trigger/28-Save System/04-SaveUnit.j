library SaveUnit requires SaveNLoad, SaveIO, OOP, Maths, SaveNLoadProgressBars, optional SaveUnitExtras, LoPWarn
/* 
This library defines functionality to save a group of units and effects using SaveIO over time. Due
to performance issues, saving all units instantly is not a good idea, as that will lag the game and may
cause disconnects.

Calling the SaveUnits function will schedule saving for a player. Every 0.5 seconds, units and effects in
the SaveUnit_PlayerData fields "effects" and "units" will be saved, 25 units at a time. This library
also handles cases where a save is made while another is not finished. In this case, the previous save
is terminated and a warning is shown to the player.

The same principles used in this library are used for SaveUnit and SaveDestructable libraries. Since
those libraries are simpler, it might be easier to understand them first before looking at this library.

This is a fairly LoP-specific implementation, though it could easily be adapted to work elsewhere.


SaveUnitExtras library:
    If this library exists, it must define the following function:
    
    function SaveUnitExtraStrings takes SaveData saveData, unit saveUnit, integer unitHandleId returns nothing
    
    This function is executed after a unit's save string is saved, and is intended to save extra information.
    In LoP, this extra information includes waygate destinations, patrol points and rects.
*/

globals
    private force ENUM_FORCE = CreateForce()
endglobals

private struct InternalPlayerData extends array
    //! runtextmacro TableStruct_NewStaticStructField("playerQueue", "LinkedHashSet")

    implement DebugPlayerStruct
    
    static key static_members_key
    //! runtextmacro TableStruct_NewStructField("saveData", "SaveData")
    static method isInitialized takes nothing returns boolean
        return playerQueueExists()
    endmethod
    
    
    // Contains units and effects to be saved
    //! runtextmacro TableStruct_NewHandleField("units", "group")
    //! runtextmacro TableStruct_NewStructField("effects", "LinkedHashSet")
    
    // Used for iteration
    //! runtextmacro TableStruct_NewPrimitiveField("savedCount", "integer")
    //! runtextmacro TableStruct_NewPrimitiveField("isSaving", "boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("total", "integer")
    
    // Required when saving a unit's position (probably will be deprecated)
    //! runtextmacro InheritFieldReadonly("SaveNLoad_PlayerData", "centerX", "real")
    //! runtextmacro InheritFieldReadonly("SaveNLoad_PlayerData", "centerY", "real")
    
    // Used for calculating save extents
    //! runtextmacro TableStruct_NewPrimitiveField("maxX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("maxY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minY", "real")
endstruct

// Public-facing struct. Users must manipulate the 'units' and 'effects' fields before calling the 'SaveUnits' function.
public struct PlayerData extends array

    //! runtextmacro InheritField("InternalPlayerData", "units", "group")
    //! runtextmacro InheritField("InternalPlayerData", "effects", "LinkedHashSet")
    
    //! runtextmacro InheritFieldReadonly("InternalPlayerData", "savedCount", "integer")
    //! runtextmacro InheritFieldReadonly("InternalPlayerData", "isSaving", "boolean")
    
endstruct

// Calculates the extents for a normal save. If the extents are smaller than 10k, then it will be saved as a Rect save.
private function CalculateRectSave takes InternalPlayerData playerId, SaveData saveData returns nothing
    local real extentX = (playerId.maxX - playerId.minX)/2
    local real extentY = (playerId.maxY - playerId.minY)/2
    
    local real centerX = playerId.maxX - extentX
    local real centerY = playerId.maxY - extentY
    
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
        set saveData.centerX = centerX
        set saveData.centerY = centerY
        set saveData.extentX = extentX
        set saveData.extentY = extentY
    endif
endfunction

private function UpdatePlayerExtents takes InternalPlayerData playerId, real x, real y returns nothing
    if x > playerId.maxX then
        set playerId.maxX = x
    endif
    if x < playerId.minX then
        set playerId.minX = x
    endif
    if y > playerId.maxY then
        set playerId.maxY = y
    endif
    if y < playerId.minY then
        set playerId.minY = y
    endif
endfunction

private function GetFacingStringEffect takes SpecialEffect sfx returns string
    if sfx.roll == 0 and sfx.pitch == 0 then
        return R2S(sfx.yaw*bj_RADTODEG)
    else
        return R2S(sfx.yaw*128) + "|" + R2S(sfx.pitch*128) + "|" + R2S(sfx.roll*128)
    endif
endfunction

private function GetScaleStringEffect takes SpecialEffect sfx returns string
    local real scaleX = sfx.scaleX
    if sfx.scaleY != scaleX  or sfx.scaleZ != scaleX then
        return R2S(sfx.scaleX) + "|" + R2S(sfx.scaleY) + "|" + R2S(sfx.scaleZ)
    else
        return R2S(sfx.scaleX)
    endif
endfunction


private function GetSFXSaveStr takes SpecialEffect whichEffect, player owner, SaveData saveData, boolean hasCustomColor, integer selectionType returns string
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
        */ GetFacingStringEffect(whichEffect) + "," +/*
        */ GetScaleStringEffect(whichEffect) + "," +/*
        */ I2S(whichEffect.red) + "," +/*
        */ I2S(whichEffect.green) + "," +/*
        */ I2S(whichEffect.blue) + "," +/*
        */ I2S(whichEffect.alpha) + "," +/*
        */ color + "," +/*
        */ R2S(whichEffect.animationSpeed) + "," +/*
        */ animTags + "," +/*
        */ I2S(selectionType)
endfunction

private function SaveEffectDecos takes InternalPlayerData playerId, SaveData saveData returns integer
    local LinkedHashSet_DecorationEffect decorations = playerId.effects
    local DecorationEffect decoration = decorations.begin()

    local integer counter = 0
    local string saveStr
    
    loop
        exitwhen counter == 25 or decorations == 0 or decoration == decorations.end()
        
        call saveData.write(SaveNLoad_FormatString("SnL_unit", GetSFXSaveStr(decoration, decoration.getOwner(), saveData, decoration.hasCustomColor, GUMS_SELECTION_UNSELECTABLE())))
        
        if not saveData.isRectSave() then
            call UpdatePlayerExtents(playerId, decoration.x, decoration.y)
        endif
        
        set decoration = decorations.next(decoration)
        call decorations.remove(decorations.prev(decoration))
        if decoration == decorations.end() then
            call decorations.destroy()
            set decorations = 0
            set playerId.effects = 0
        endif

        set counter = counter + 1
    endloop
    
    return counter
endfunction

private function GenerateFlagsStr takes unit saveUnit returns string
    local integer result = 0
    if LoP_IsUnitDecoration(saveUnit) and not ObjectPathing.get(saveUnit).isDisabled then
        set result = result + SaveNLoad_BoolFlags.UNROOTED
    elseif IsUnitType(saveUnit, UNIT_TYPE_ANCIENT) and BlzGetUnitIntegerField(saveUnit, UNIT_IF_DEFENSE_TYPE) == GetHandleId(DEFENSE_TYPE_LARGE) then
        set result = result + SaveNLoad_BoolFlags.UNROOTED
    endif
    if GetOwningPlayer(saveUnit) == Player(PLAYER_NEUTRAL_PASSIVE) then
        set result = result + SaveNLoad_BoolFlags.NEUTRAL
    endif
    return I2S(result)  // TODO: If max flag exceeds 4, we need to use AnyBase(92) instead of I2S
endfunction

private function SaveNextUnits takes player filterPlayer returns boolean
    local InternalPlayerData playerId = GetPlayerId(filterPlayer)
    local unit saveUnit
    local integer saveUnitCount = 0
    local string saveStr
    local UnitVisuals unitHandleId
    local SaveData saveData
    local group grp
    
    if playerId.savedCount == 0 then
        set playerId.total = BlzGroupGetSize(playerId.units) + playerId.effects.size()  // count total here to avoid OP limit
    endif
    
    if playerId.isSaving == true then
        set saveData = playerId.saveData
        
        set saveUnitCount = SaveEffectDecos(playerId, saveData)  // Only begin saving units once all decorations have been saved.
        loop
        exitwhen saveUnitCount >= 25
            set grp = playerId.units
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
                    set saveStr = GetSFXSaveStr(GetUnitAttachedEffect(saveUnit), filterPlayer, saveData, unitHandleId.hasColor(), GUMS_GetUnitSelectionType(saveUnit))
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
                                */   GenerateFlagsStr(saveUnit)
                endif
                
                call saveData.write(SaveNLoad_FormatString("SnL_unit", saveStr))
                
                if not saveData.isRectSave() then
                    call UpdatePlayerExtents(playerId, GetUnitX(saveUnit), GetUnitY(saveUnit))
                endif
                
                if GUMSUnitHasCustomName(unitHandleId) then
                    call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=n " + SaveIO_CleanUpString(GUMSGetUnitName(saveUnit))))
                endif
                
                static if LIBRARY_SaveUnitExtras then
                    call SaveUnitExtraStrings(saveData, saveUnit, unitHandleId)
                endif
            endif
                
            //This block should be below the group refresh check in order to always produce correct results
            if IsGroupEmpty(grp) then
                set playerId.isSaving = false
                call DisplayTextToPlayer(filterPlayer,0,0, "Finished Saving" )
                if User.fromLocal() == playerId then
                    call BlzFrameSetVisible(saveUnitBar, false)
                endif
                exitwhen true
            endif
                
            set saveUnitCount = saveUnitCount +1
        endloop
        
        //This if statement must remain inside (if playerId.isSaving == true) statement to avoid output for people who aren't saving
        if playerId.isSaving == false then
            if not saveData.isRectSave() then
                call CalculateRectSave(playerId, saveData)
            endif
            call saveData.destroy()
            // call playerId.effects.destroy()
            set playerId.saveData = 0
        else
            set playerId.savedCount = playerId.savedCount + 1
            if User.fromLocal() == playerId then
                call BlzFrameSetText(saveUnitBarText, I2S(playerId.savedCount*25)+"/"+I2S(playerId.total))
                call BlzFrameSetValue(saveUnitBar, 100.*playerId.savedCount*25/I2R(playerId.total))
            endif
        endif
    endif
    
    set saveUnit = null
    return false
endfunction

private function SaveLoopActions takes nothing returns nothing
    local InternalPlayerData playerId
    local LinkedHashSet queue = InternalPlayerData.playerQueue
    
    if not queue.isEmpty() then
        set playerId = queue.getFirst() - 1
        call queue.remove(playerId+1)
        
        call SaveNextUnits(Player(playerId))
    
        if playerId.isSaving then
            call queue.append(playerId+1)
        endif
    endif
endfunction

function SaveUnits takes SaveData saveData returns nothing
    local InternalPlayerData playerId = GetPlayerId(saveData.player)
    
    if not InternalPlayerData.isInitialized() then  // avoid creating an extra function
        set InternalPlayerData.playerQueue = LinkedHashSet.create()
    endif

    set playerId.savedCount = 0
    set playerId.isSaving = true
    
    set playerId.maxX = -Pow(2, 23)
    set playerId.minX = Pow(2, 23)
    set playerId.maxY = -Pow(2, 23)
    set playerId.minY = Pow(2, 23)
    
    if playerId.saveData != 0 then
        call LoP_WarnPlayer(saveData.player, LoPChannels.WARNING, "Did not finish saving previous file!")
        call playerId.saveData.destroy()
    else
        call InternalPlayerData.playerQueue.append(playerId + 1)
    endif
    set playerId.saveData = saveData
    
    
    if User.fromLocal() == playerId then
        call BlzFrameSetText(saveUnitBarText, "Waiting...")
        call BlzFrameSetVisible(saveUnitBar, true)
        call BlzFrameSetValue(saveUnitBar, 0.)
    endif
endfunction


//===========================================================================
function InitTrig_SaveUnit takes nothing returns nothing
    call TimerStart(CreateTimer(), 0.5, true, function SaveLoopActions)
endfunction
endlibrary
