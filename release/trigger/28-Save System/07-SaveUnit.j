library SaveUnit requires SaveNLoad, SaveIO, optional LoPHeroicUnit, optional CustomizableAbilityList

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


function GetSFXSaveStr takes SpecialEffect whichEffect, player owner, boolean hasCustomColor, integer selectionType returns string
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
        */ R2S(whichEffect.x - playerId.centerX) + "," +/*
        */ R2S(whichEffect.y - playerId.centerY) + "," +/*
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

function SaveEffectDecos takes integer playerNumber, SaveData saveData returns integer
    local LinkedHashSet_DecorationEffect decorations = save_decoration_effects[playerNumber]
    local DecorationEffect decoration = decorations.begin()

    local integer counter = 0
    local string saveStr
    
    loop
        exitwhen counter == 25 or decorations == 0 or decoration == decorations.end()
        
        call saveData.write(SaveNLoad_FormatString("SnL_unit", GetSFXSaveStr(decoration, decoration.getOwner(), decoration.hasCustomColor, GUMS_SELECTION_UNSELECTABLE())))
        
        set decoration = decorations.next(decoration)
        call decorations.remove(decorations.prev(decoration))
        if decoration == decorations.end() then
            call decorations.destroy()
            set decorations = 0
            set save_decoration_effects[playerNumber] = 0
        endif

        set counter = counter + 1
    endloop
    
    return counter
endfunction

globals
    SaveData array saveFile
endglobals

function SaveForceLoop takes nothing returns boolean
    local player filterPlayer = GetFilterPlayer()
    local SaveNLoad_PlayerData playerId = GetPlayerId(filterPlayer)
    local integer playerNumber = playerId + 1
    local unit saveUnit
    local integer saveUnitCount = 0
    local string saveStr
    local UnitVisuals unitHandleId
    local SaveData saveData
    
    if udg_save_load_boolean[playerNumber] == true then
        set stillSaving = true
        if saveFile[playerId] == 0 then
            set saveFile[playerId] = SaveData.create(filterPlayer, SaveNLoad_FOLDER() + udg_save_password[playerNumber])
        endif
        set saveData = saveFile[playerId]
        
        set saveUnitCount = SaveEffectDecos(playerNumber, saveData)  // Only begin saving units once all decorations have been saved.
        loop
        exitwhen saveUnitCount >= 25
            set saveUnit = FirstOfGroup(udg_save_grp[playerNumber])
            set unitHandleId = GetHandleId(saveUnit)
            call GroupRemoveUnit(udg_save_grp[playerNumber] , saveUnit)

            //Check if Unit has been removed
            if saveUnit == null then
                // Removed unit
                if not IsGroupEmpty(udg_save_grp[playerNumber]) then
                    call GroupRefresh(udg_save_grp[playerNumber])
                endif
            else
                if UnitHasAttachedEffect(saveUnit) then
                    set saveStr = GetSFXSaveStr(GetUnitAttachedEffect(saveUnit), filterPlayer, unitHandleId.hasColor(), GUMS_GetUnitSelectionType(saveUnit))
                else
                    set saveStr = ID2S((GetUnitTypeId(saveUnit))) + "," + /*
                                */   R2S(GetUnitX(saveUnit) - playerId.centerX)+","+  /*
                                */   R2S(GetUnitY(saveUnit) - playerId.centerY) + "," + /*
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
                                */   I2S(GUMS_GetUnitSelectionType(saveUnit))
                endif
                
                call saveData.write(SaveNLoad_FormatString("SnL_unit", saveStr))
                
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
            if IsGroupEmpty(udg_save_grp[playerNumber]) then
                set udg_save_load_boolean[playerNumber] = false
                call DisplayTextToPlayer(filterPlayer,0,0, (I2S(udg_save_unit_nmbr[playerNumber])))
                call DisplayTextToPlayer(filterPlayer,0,0, "Finished Saving" )
                exitwhen true
            endif
                
            set saveUnitCount = saveUnitCount +1
        endloop
        
        //This if statement must remain inside (if udg_save_load_boolean[playerNumber] == true) statement to avoid output for people who aren't saving
        if udg_save_load_boolean[playerNumber] == false then
            call saveData.destroy()
            call save_decoration_effects[playerNumber].destroy()
            set saveFile[playerId] = 0
        else
            call DisplayTextToPlayer(filterPlayer,0,0, (I2S(udg_save_unit_nmbr[playerNumber])))
            set udg_save_unit_nmbr[playerNumber] = ( udg_save_unit_nmbr[playerNumber] + 1 )
        endif
    endif
    
    set saveUnit = null
    return false
endfunction

function SaveLoopActions takes nothing returns nothing

    debug call BJDebugMsg("SaveLoop Timer executed")

    set stillSaving = false
    call ForceEnumPlayers(ENUM_FORCE, Condition(function SaveForceLoop))
    
    if not stillSaving then
        call PauseTimer(GetExpiredTimer())
    endif

endfunction

function SaveLoopStartTimer takes nothing returns nothing
    
    if not stillSaving then
        call TimerStart(loopTimer, 0.5, true, function SaveLoopActions)
    endif
    
endfunction


//===========================================================================
function InitTrig_SaveUnit takes nothing returns nothing
    set loopTimer = CreateTimer()
    
    call TimerStart(loopTimer, 0.5, true, function SaveLoopActions)
endfunction
endlibrary
