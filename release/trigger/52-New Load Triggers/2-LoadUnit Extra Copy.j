function Trig_LoadUnitNew_Extra_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local string eventStr = BlzGetTriggerSyncData()// GetEventPlayerChatString()
    local string cmdStr = SubStringBJ(eventStr, 1, 3)
    
    if     cmdStr == "=n " then
        call GUMSSetUnitName(udg_save_LastLoadedUnit[playerId], SubString(eventStr, 3, StringLength(eventStr)))
    elseif cmdStr == "=w " then
        call Load_RestoreWaygate(SubString(eventStr, 3, StringLength(eventStr)), udg_save_LastLoadedUnit[playerId])
    elseif cmdStr == "=p " then
        static if LIBRARY_MultiPatrol then
            call Load_RestorePatrolPoints(udg_save_LastLoadedUnit[playerId], SubString(eventStr, 3, StringLength(eventStr)))
        endif
    else
        static if LIBRARY_UserDefinedRects then
            call Load_RestoreGUDR(udg_save_LastLoadedUnit[playerId], eventStr)
        endif
    endif
endfunction

//===========================================================================
function InitTrig_LoadUnit_Extra_Copy takes nothing returns nothing
    set gg_trg_LoadUnit_Extra_Copy = CreateTrigger(  )
    call TriggerAddAction( gg_trg_LoadUnit_Extra_Copy, function Trig_LoadUnitNew_Extra_Actions )
    call BlzTriggerRegisterPlayerSyncEvent( gg_trg_LoadUnit_Extra_Copy, Player(0), "SnL_unit_extra", false)
endfunction

