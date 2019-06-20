library SaveUnit requires SaveNLoad, SaveIO

globals
    force ENUM_FORCE = CreateForce()
    boolean stillSaving = false
    timer loopTimer
endglobals

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

function GenerateSpecialEffectSaveString takes SpecialEffect whichEffect returns string
    return ID2S(whichEffect.unitType) + "," +/*
        */ R2S(whichEffect.x) + "," +/*
        */ R2S(whichEffect.y) + "," +/*
        */ R2S(whichEffect.height) + "," +/*
        */ R2S(Rad2Deg(whichEffect.yaw)) + "," +/*
        */ R2S(whichEffect.scaleX) + "," +/*
        */ I2S(whichEffect.red) + "," +/*
        */ I2S(whichEffect.green) + "," +/*
        */ I2S(whichEffect.blue) + "," +/*
        */ I2S(whichEffect.alpha) + "," +/*
        */ I2S(whichEffect.color + 1) + "," +/*
        */ R2S(whichEffect.animationSpeed) + "," +/*
        */ GUMSConvertTags(UnitVisualMods_TAGS_COMPRESS, SubAnimations2Tags(whichEffect.subanimations)) + "," +/*
        */ I2S(GUMS_SELECTION_UNSELECTABLE())
endfunction

function SaveEffectDecos takes integer playerNumber, SaveData saveData returns integer
    local LinkedHashSet_DecorationEffect decorations = save_decoration_effects[playerNumber]
    local DecorationEffect decoration = decorations.begin()

    local integer counter = 0
    local string saveStr
    
    loop
        exitwhen counter == 25 or decorations == 0 or decoration == decorations.end()
        
        call saveData.write(SaveNLoad_FormatString("SnL_unit", GenerateSpecialEffectSaveString(decoration)))
        
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
    local integer playerId = GetPlayerId(GetFilterPlayer())
    local integer playerNumber = playerId + 1
    local unit saveUnit
    local integer saveUnitCount = 0
    local string saveStr
    local UnitVisuals unitHandleId
    local SaveData saveData
    
    if udg_save_load_boolean[playerNumber] == true then
        set stillSaving = true
        if saveFile[playerId] == 0 then
            set saveFile[playerId] = SaveData.create(Player(playerId), SaveNLoad_FOLDER() + udg_save_password[playerNumber])
        endif
        set saveData = saveFile[playerId]
        
        set saveUnitCount = SaveEffectDecos(playerNumber, saveData)
        loop
        exitwhen saveUnitCount >= 25
            set saveUnit = FirstOfGroup(udg_save_grp[playerNumber])
            set unitHandleId = GetHandleId(saveUnit)
            call GroupRemoveUnit(udg_save_grp[playerNumber] , saveUnit)

            //Check if Unit has been removed
            if GetUnitTypeId(saveUnit) != 0 then
            
                set saveStr = ID2S((GetUnitTypeId(saveUnit))) + "," + /*
                            */   R2S(GetUnitX(saveUnit) - Save_GetCenterX(playerId))+","+  /*
                            */   R2S(GetUnitY(saveUnit) - Save_GetCenterY(playerId)) + "," + /*
                            */   R2S(GetUnitFlyHeight(saveUnit)) + "," + /*
                            */   R2S(GetUnitFacing(saveUnit)) + "," + /*
                            */   unitHandleId.getScale() + "," + /*
                            */   unitHandleId.getVertexRed() + "," + /*
                            */   unitHandleId.getVertexGreen() + "," + /*
                            */   unitHandleId.getVertexBlue() + "," + /*
                            */   unitHandleId.getVertexAlpha() + "," + /*
                            */   unitHandleId.getColor() + "," + /*
                            */   unitHandleId.getAnimSpeed() + "," + /*
                            */   unitHandleId.getAnimTag() + "," + /*
                            */   I2S(GUMS_GetUnitSelectionType(saveUnit))
                
                call saveData.write(SaveNLoad_FormatString("SnL_unit", saveStr))
                
                if GUMSUnitHasCustomName(unitHandleId) then
                    call saveData.write(SaveNLoad_FormatString("SnL_unit_extra", "=n " + GUMSGetUnitName(saveUnit)))
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
            else
                /*
                set saveStr = "Removed Unit"
                if isLocalPlayer then
                    call Preload(saveStr)
                endif
                */
                call GroupRefresh(udg_save_grp[playerNumber])
            endif
            //End of Check
                
            //This block should be below the group refresh check in order to always produce correct results
            if IsGroupEmpty(udg_save_grp[playerNumber]) then
                set udg_save_load_boolean[playerNumber] = false
                call DisplayTextToPlayer( Player(playerNumber - 1),0,0, "Finished Saving" )
                exitwhen true
            endif
                
            set saveUnitCount = saveUnitCount +1
        endloop //saveUnitCount should be set to zero at the start of this loop
        
        //This if statement must remain inside (if udg_save_load_boolean[playerNumber] == true) statement to avoid output for people who aren't saving
        call DisplayTextToPlayer(Player(playerNumber - 1), 0, 0, (I2S(udg_save_unit_nmbr[playerNumber])))
        set udg_save_unit_nmbr[playerNumber] = ( udg_save_unit_nmbr[playerNumber] + 1 )
        if udg_save_load_boolean[playerNumber] == false then
            call saveData.destroy()
            set saveFile[playerId] = 0
            // call SaveSize(Player(playerNumber - 1), udg_save_password[playerNumber], udg_save_unit_nmbr[playerNumber])
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

