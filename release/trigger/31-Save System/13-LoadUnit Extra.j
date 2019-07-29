static if LIBRARY_MultiPatrol then
    function Load_RestorePatrolPoints takes unit whichUnit, string chatStr returns nothing
        local integer cutToComma = CutToCharacter(chatStr, "=")
        local real x = S2R(CutToCommaResult(chatStr, cutToComma))
        local real y
        
        set chatStr = CutToCommaShorten(chatStr, cutToComma)
        set cutToComma = CutToCharacter(chatStr, "=")
        set y = S2R(CutToCommaResult(chatStr, cutToComma))
        
        
        // TODO: Create function to set first patrol in the GPS library
        if not Patrol_UnitHasPatrolPoints(whichUnit) then
            call SetUnitPosition(whichUnit, x, y)
            call Patrol_SetCurrentPatrolPoint(GetHandleId(whichUnit), 1)
        else
            call Patrol_RegisterPoint(whichUnit, x, y)
        endif
        
    endfunction
endif

function Load_RestoreWaygate takes string ha, unit whichGate returns nothing
    local integer cutToComma = CutToCharacter(ha, "=")
    local real wayGateX = S2R(CutToCommaResult(ha, cutToComma))
    local real wayGateY
    local string activate

    set ha = CutToCommaShorten(ha, cutToComma)
    set cutToComma = CutToCharacter(ha, "=")
    set wayGateY = S2R(CutToCommaResult(ha, cutToComma))
    set ha = CutToCommaShorten(ha, cutToComma)
    set cutToComma = CutToCharacter(ha, "=")
    set activate = CutToCommaResult(ha, cutToComma)
    
    call WaygateSetDestination(whichGate, wayGateX, wayGateY)
    if activate == "T" then
        call WaygateActivate(whichGate, true)
    else
        call WaygateActivate(whichGate, false)
    endif
endfunction

function Trig_LoadUnit_Extra_Actions takes nothing returns nothing
    local integer playerId = GetPlayerId(GetTriggerPlayer())
    local string eventStr = GetEventPlayerChatString()
    local string cmdStr = SubStringBJ(eventStr, 1, 3)
    
    if not Save_IsPlayerLoading(playerId) then
        return
    endif
    
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
function InitTrig_LoadUnit_Extra takes nothing returns nothing
    set gg_trg_LoadUnit_Extra = CreateTrigger(  )
    call DisableTrigger( gg_trg_LoadUnit_Extra )
    call TriggerAddAction( gg_trg_LoadUnit_Extra, function Trig_LoadUnit_Extra_Actions )
endfunction

