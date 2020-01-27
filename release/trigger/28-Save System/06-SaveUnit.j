library SaveUnit requires SaveNLoad, SaveIO, OOP, Maths, optional LoPHeroicUnit, optional CustomizableAbilityList

globals
    SaveData array saveFile
endglobals

private struct InternalPlayerData extends array

    implement DebugPlayerStruct

    group units
    LinkedHashSet effects
    integer savedCount
    boolean isSaving
    
    //! runtextmacro InheritFieldReadonly("SaveNLoad_PlayerData", "centerX", "real")
    //! runtextmacro InheritFieldReadonly("SaveNLoad_PlayerData", "centerY", "real")
    
    //! runtextmacro TableStruct_NewPrimitiveField("maxX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minX", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("maxY", "real")
    //! runtextmacro TableStruct_NewPrimitiveField("minY", "real")
endstruct

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

function UpdatePlayerExtents takes InternalPlayerData playerId, real x, real y returns nothing
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

public struct PlayerData extends array

    //! runtextmacro InheritField("InternalPlayerData", "units", "group")
    //! runtextmacro InheritField("InternalPlayerData", "effects", "LinkedHashSet")
    
    //! runtextmacro InheritFieldReadonly("InternalPlayerData", "savedCount", "integer")
    //! runtextmacro InheritFieldReadonly("InternalPlayerData", "isSaving", "boolean")
    
endstruct

globals
    force ENUM_FORCE = CreateForce()
    boolean stillSaving = false
    timer loopTimer
endglobals

private function EncodeRemoveableAbilities takes unit whichUnit returns string
    local ArrayList_ability abilities = UnitEnumRemoveableAbilities(whichUnit)
    local integer i = 0
    local string result = "=a "
    
    loop
    exitwhen i == abilities.end()
        set result = result + ID2S(RemoveableAbility.fromAbility(abilities[i])) + ","
        set i = abilities.next(i)
    endloop
    
    call abilities.destroy()
    return result
endfunction

function IsUnitWaygate takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'Awrp') > 0
endfunction

function Save_PatrolPointStr takes real x, real y returns string
    return SaveNLoad_FormatString("SnL_unit_extra", "=p " + R2S(x) + "=" +  R2S(y))
endfunction

function Save_SaveUnitPatrolPoints takes SaveData saveData, integer unitHandleId returns nothing
    local integer i = 1
    local integer totalPoints = Patrol_GetTotalPatrolPoints(unitHandleId)
    local string saveStr
    
    loop
    exitwhen i > totalPoints
        call saveData.write(Save_PatrolPointStr(Patrol_GetPointX(unitHandleId, i),Patrol_GetPointY(unitHandleId, i)))
        set i = i+1
    endloop
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
    if IsUnitType(saveUnit, UNIT_TYPE_ANCIENT) and BlzGetUnitIntegerField(saveUnit, UNIT_IF_DEFENSE_TYPE) == GetHandleId(DEFENSE_TYPE_LARGE) then
        set result = result + SaveNLoad_BoolFlags.UNROOTED
    endif
    if GetOwningPlayer(saveUnit) == Player(PLAYER_NEUTRAL_PASSIVE) then
        set result = result + SaveNLoad_BoolFlags.NEUTRAL
    endif
    return I2S(result)  // TODO: If max flag exceeds 4, we need to use AnyBase(92) instead of I2S
endfunction

private function SaveForceLoop takes nothing returns boolean
    local player filterPlayer = GetFilterPlayer()
    local InternalPlayerData playerId = GetPlayerId(filterPlayer)
    local unit saveUnit
    local integer saveUnitCount = 0
    local string saveStr
    local UnitVisuals unitHandleId
    local SaveData saveData
    local group grp 
    
    if playerId.isSaving == true then
        set stillSaving = true
        set saveData = saveFile[playerId]
        
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
                
                if GUDR_IsUnitIdGenerator(unitHandleId) then
                    call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", Save_GetGUDRSaveString(unitHandleId)))
                endif
                
                if IsUnitWaygate(saveUnit) then
                    if WaygateIsActive(saveUnit) then
                        call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=w " + R2S(WaygateGetDestinationX(saveUnit)) + "=" + R2S(WaygateGetDestinationY(saveUnit)) + "=T="))
                    else
                        call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=w " + R2S(WaygateGetDestinationX(saveUnit)) + "=" + R2S(WaygateGetDestinationY(saveUnit)) + "=F="))
                    endif
                endif
                
                if Patrol_UnitIdHasPatrolPoints(unitHandleId) then
                    call Save_SaveUnitPatrolPoints(saveData, unitHandleId)
                endif
                
                static if LIBRARY_LoPHeroicUnit then
                    if LoP_IsUnitCustomHero(saveUnit) then
                        call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=h S"))
                    endif
                endif
                
                static if LIBRARY_CustomizableAbilityList then
                    if GetUnitAbilityLevel(saveUnit, 'AHer') > 0 then
                        call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", EncodeRemoveableAbilities(saveUnit)))
                    endif
                endif
            endif
                
            //This block should be below the group refresh check in order to always produce correct results
            if IsGroupEmpty(grp) then
                set playerId.isSaving = false
                call DisplayTextToPlayer(filterPlayer,0,0, (I2S(playerId.savedCount)))
                call DisplayTextToPlayer(filterPlayer,0,0, "Finished Saving" )
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
            set saveFile[playerId] = 0
        else
            call DisplayTextToPlayer(filterPlayer,0,0, (I2S(playerId.savedCount)))
            set playerId.savedCount = playerId.savedCount + 1
        endif
    endif
    
    set saveUnit = null
    return false
endfunction

private function SaveLoopActions takes nothing returns nothing

    debug call BJDebugMsg("SaveLoop Timer executed")

    set stillSaving = false
    call ForceEnumPlayers(ENUM_FORCE, Condition(function SaveForceLoop))
    
    if not stillSaving then
        call PauseTimer(GetExpiredTimer())
    endif

endfunction

function SaveUnits takes SaveData saveData returns nothing
    local InternalPlayerData playerId = GetPlayerId(saveData.player)

    set playerId.savedCount = 0
    set playerId.isSaving = true
    
    set playerId.maxX = -Pow(2, 23)
    set playerId.minX = Pow(2, 23)
    set playerId.maxY = -Pow(2, 23)
    set playerId.minY = Pow(2, 23)
    
    if saveFile[playerId] != 0 then
        call DisplayTextToPlayer(saveData.player, 0., 0., "|cffff0000Warning:|r Did not finish saving previous file!")
        call saveFile[playerId].destroy()
    endif
    set saveFile[playerId] = saveData
    
    if not stillSaving then
        call TimerStart(loopTimer, 0.5, true, function SaveLoopActions)
    endif
    
endfunction


//===========================================================================
function InitTrig_SaveUnit takes nothing returns nothing
    set loopTimer = CreateTimer()
endfunction
endlibrary
