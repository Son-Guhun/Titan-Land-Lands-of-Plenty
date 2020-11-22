library SaveUnit requires SaveNLoadUnit, Maths, SaveNLoadProgressBars, /*

// Libraries whose values are serialized when saving:
*/ UnitVisualValues, DecorationSFX, AttachedSFX, /*

// Optional library for further unit serialization:
*/ optional SaveUnitExtras

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
    
    method hasUnits takes nothing returns boolean
        return units_exists()
    endmethod
    
    method hasEffects takes nothing returns boolean
        return effects_exists()
    endmethod
    
    method isFinished takes nothing returns boolean
        return not ((.units_exists() and not IsGroupEmpty(.units)) or (.effects_exists() and not .effects.isEmpty()))
    endmethod
    
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
            
            call saveWriter.write(SaveNLoad_FormatString("SnL_unit", SerializeSpecialEffect(decoration, decoration.getOwner(), decoration.hasCustomColor, UnitVisuals.SELECTION_UNSELECTABLE, SerializeSpecialEffectFlags(decoration))))
            
            if not saveWriter.isRectSave() then
                call .updateExtents(decoration.x, decoration.y)
            endif
            
            set decoration = decorations.next(decoration)
            call decorations.remove(decorations.prev(decoration))

            set counter = counter + 1
        endloop
        
        return counter
    endmethod

    method saveNextUnits takes nothing returns boolean
        local SaveWriter saveWriter = .saveWriter
        local unit saveUnit
        local integer saveUnitCount = 0
        local group grp
        
        if .savedCount == 0 then
            set .total = BlzGroupGetSize(.units) + .effects.size()  // count total here to avoid OP limit
        endif
        
        set saveUnitCount = .saveNextEffects()  // Only begin saving units once all decorations have been saved.
        set grp = .units
        loop
            exitwhen saveUnitCount >= BATCH_SIZE or IsGroupEmpty(grp)
            
            set saveUnit = FirstOfGroup(grp)
            call GroupRemoveUnit(grp, saveUnit)

            if saveUnit == null then
                call GroupRefresh(grp)  // Removed unit, refresh group to get next
            elseif (IsUnitHidden(saveUnit) and not IsUnitLoaded(saveUnit)) or not UnitAlive(saveUnit) then
                // Do nothing           // Don't save dead and hidden units
            else
                call saveWriter.write(SaveNLoad_FormatString("SnL_unit", SerializeUnit(saveUnit)))
                
                if not saveWriter.isRectSave() then
                    call .updateExtents(GetUnitX(saveUnit), GetUnitY(saveUnit))
                endif
                
                static if LIBRARY_SaveUnitExtras then
                    call SaveUnitExtraStrings(saveWriter, saveUnit, GetHandleId(saveUnit))
                endif
            endif

            set saveUnitCount = saveUnitCount +1
        endloop
        
        if IsGroupEmpty(grp) and .effects.isEmpty() then
            call DisplayTextToPlayer(saveWriter.player,0,0, "Finished Saving" )
            if not saveWriter.isRectSave() then
                call .calculateRectSave()
            endif
        else
            set .savedCount = .savedCount + 1
            if User.Local == saveWriter.player then
                call BlzFrameSetText(saveProgressBarText, I2S(.savedCount*BATCH_SIZE)+ "/" +I2S(.total))
                call BlzFrameSetValue(saveProgressBar, 100.*.savedCount*BATCH_SIZE / I2R(.total))
            endif
        endif
        
        set saveUnit = null
        set grp = null
        return false
    endmethod
endstruct

endlibrary
