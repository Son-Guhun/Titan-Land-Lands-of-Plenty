function Trig_System_Limit_Type_Change_Conditions takes nothing returns boolean
    
    // A unit being dead here is unlikely, so it's better for performance to initialize the local
    local unit triggerUnit = udg_UDexUnits[udg_UDex]
    
    if udg_IsUnitAlive[udg_UDex] then
    
        if Limit_IsPlayerLimited(GetOwningPlayer(triggerUnit)) then
        
            call Limit_UnregisterUnit(triggerUnit)
            
            if Limit_IsUnitLimited(triggerUnit) then
                call Limit_RegisterUnit(triggerUnit)
            endif
        endif
    endif

    set triggerUnit = null
    return false
endfunction

//===========================================================================
function InitTrig_System_Limit_Type_Change takes nothing returns nothing
    set gg_trg_System_Limit_Type_Change = CreateTrigger(  )
    call TriggerRegisterVariableEvent( gg_trg_System_Limit_Type_Change, "udg_UnitTypeEvent", EQUAL, 1.00 )
    call TriggerAddCondition( gg_trg_System_Limit_Type_Change, Condition( function Trig_System_Limit_Type_Change_Conditions ) )
endfunction

