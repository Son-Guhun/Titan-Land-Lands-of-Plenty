function Trig_System_Limit_Register_Conditions takes nothing returns boolean

    // A unit being dead here is unlikely, so it's better for performance to initialize the local
    local unit triggerUnit = udg_UDexUnits[udg_UDex]
    
    if udg_IsUnitAlive[udg_UDex] and not udg_IsUnitReincarnating[udg_UDex] then
        if Limit_IsPlayerLimited(GetOwningPlayer(triggerUnit)) and Limit_IsUnitLimited(triggerUnit) then
            call Limit_RegisterUnit(triggerUnit)
        endif
    endif

    set triggerUnit = null
    return false
endfunction

//===========================================================================
function InitTrig_System_Limit_Register takes nothing returns nothing
    set gg_trg_System_Limit_Register = CreateTrigger(  )
    call TriggerRegisterVariableEvent( gg_trg_System_Limit_Register, "udg_UnitIndexEvent", EQUAL, 1.00 )
    call TriggerRegisterVariableEvent( gg_trg_System_Limit_Register, "udg_DeathEvent", EQUAL, 2.00 )
    call TriggerAddCondition( gg_trg_System_Limit_Register, Condition( function Trig_System_Limit_Register_Conditions ) )
endfunction

