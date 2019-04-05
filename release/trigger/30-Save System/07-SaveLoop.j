function IsUnitWaygate takes unit whichUnit returns boolean
    return GetUnitAbilityLevel(whichUnit, 'Awrp') > 0
endfunction

function Save_PreloadPatrolPoint takes real x, real y returns nothing
    call Preload("=p " + R2S(x) + "=" +  R2S(y))
endfunction

function Save_SaveUnitPatrolPoints takes integer unitHandleId returns nothing
    local integer i = 1
    local integer totalPoints = Patrol_GetTotalPatrolPoints(unitHandleId)
    
    loop
    exitwhen i > totalPoints
        call Save_PreloadPatrolPoint(Patrol_GetPointX(unitHandleId, i),Patrol_GetPointY(unitHandleId, i))
        set i = i+1
    endloop
endfunction

function SaveForceLoop takes nothing returns boolean
    local integer playerId = GetPlayerId(GetFilterPlayer())
    local integer playerNumber = playerId + 1
    local unit saveUnit
    local integer saveUnitCount = 0
    local boolean isLocalPlayer = false
    local string saveString
    local integer unitHandleId
    
    if udg_save_load_boolean[playerNumber] == true then
        if ( GetLocalPlayer() == Player(playerNumber - 1) ) then
            set isLocalPlayer = true
            call PreloadGenStart()
            call PreloadGenClear()
        endif
        loop
        exitwhen saveUnitCount >= 25
            set saveUnit = FirstOfGroup(udg_save_grp[playerNumber])
            set unitHandleId = GetHandleId(saveUnit)
            call GroupRemoveUnit(udg_save_grp[playerNumber] , saveUnit)

            //Check if Unit has been removed
            if GetUnitTypeId(saveUnit) != 0 then
                if isLocalPlayer then
                    call Preload(ID2S((GetUnitTypeId(saveUnit))) + "," + R2S(GetUnitX(saveUnit) - Save_GetCenterX(playerId))+","+ R2S(GetUnitY(saveUnit) - Save_GetCenterY(playerId)) + "," + R2S(GetUnitFlyHeight(saveUnit)) + "," + R2S(GetUnitFacing(saveUnit)) + "," + GUMSGetUnitScale(saveUnit) + "," + GUMSGetUnitVertexColor(saveUnit,1) + "," + GUMSGetUnitVertexColor(saveUnit,2) + "," + GUMSGetUnitVertexColor(saveUnit,3) + "," + GUMSGetUnitVertexColor(saveUnit,4) + "," + GUMSGetUnitColor(saveUnit) + "," + GUMSGetUnitAnimSpeed(saveUnit) + "," + GUMSGetUnitAnimationTag(saveUnit) + "," + I2S(GUMS_GetUnitSelectionType(saveUnit)))
                    if GUMSUnitHasCustomName(unitHandleId) then
                        call Preload("=n " + GUMSGetUnitName(saveUnit))
                    endif
                    if GUDR_IsUnitIdGenerator(unitHandleId) then
                        call Preload(Save_GetGUDRSaveString(unitHandleId))
                    endif
                    if IsUnitWaygate(saveUnit) then
                        if WaygateIsActive(saveUnit) then
                            call Preload("=w " + R2S(WaygateGetDestinationX(saveUnit)) + "=" + R2S(WaygateGetDestinationY(saveUnit)) + "=T=")
                        else
                            call Preload("=w " + R2S(WaygateGetDestinationX(saveUnit)) + "=" + R2S(WaygateGetDestinationY(saveUnit)) + "=F=")
                        endif
                    endif
                    if Patrol_UnitIdHasPatrolPoints(unitHandleId) then
                        call Save_SaveUnitPatrolPoints(unitHandleId)
                    endif
                endif
            else
                if isLocalPlayer then
                    call Preload("Removed Unit")
                endif
                call GroupRefresh(udg_save_grp[playerNumber])
            endif
            //End of Check
                
            //This block should be below the group refresh check in order to always produce correct results
            if IsGroupEmpty(udg_save_grp[playerNumber]) then
                set udg_save_load_boolean[playerNumber] = false
                call DisplayTextToPlayer( Player(playerNumber - 1),0,0, "Finished Saving" )
                set saveUnitCount =  99//No need to check for more units, get off the loop
            endif
            //End of block that should be below
                
            set saveUnitCount = saveUnitCount +1
        endloop //saveUnitCount should be set to zero at the start of this loop
        
        //This if statement must remain inside (if udg_save_load_boolean[playerNumber] == true) statement to avoid output for people who aren't saving
        if isLocalPlayer then
            call PreloadGenEnd("DataManager\\" + udg_save_password[playerNumber] + "\\" + I2S(udg_save_unit_nmbr[playerNumber]) + ".txt")
            call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, (I2S(udg_save_unit_nmbr[playerNumber])))
            set udg_save_unit_nmbr[playerNumber] = ( udg_save_unit_nmbr[playerNumber] + 1 )
            if udg_save_load_boolean[playerNumber] == false then
                call SaveSize(udg_save_password[playerNumber], udg_save_unit_nmbr[playerNumber])
            endif
        endif
    endif
    //End of if statement
    
    set saveUnit = null
    return false
endfunction

function SaveLoopActions takes nothing returns nothing
    local force savePlayers = CreateForce()
    
    call ForceEnumPlayers(savePlayers, Condition(function SaveForceLoop))
    
    call DestroyForce(savePlayers)
    set savePlayers = null
endfunction

//===========================================================================
function InitTrig_SaveLoop takes nothing returns nothing
    set gg_trg_SaveLoop = CreateTrigger(  )
    call TriggerRegisterTimerEventPeriodic( gg_trg_SaveLoop, 0.50 )
    call TriggerAddAction( gg_trg_SaveLoop, function SaveLoopActions )
endfunction

