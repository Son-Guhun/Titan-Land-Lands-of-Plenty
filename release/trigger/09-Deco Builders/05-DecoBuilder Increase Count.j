function Trig_DecoBuilder_Increase_Count_Conditions takes nothing returns boolean
    local unit u = udg_UDexUnits[udg_UDex]
    
    if LoP_IsUnitDecoBuilder(u) then
        call DecoBuilderCount_IncreaseCount(u)
    endif
    
    set u = null
    return true
endfunction

//===========================================================================
function InitTrig_DecoBuilder_Increase_Count takes nothing returns nothing
    set gg_trg_DecoBuilder_Increase_Count = CreateTrigger(  )
    call TriggerRegisterVariableEvent( gg_trg_DecoBuilder_Increase_Count, "udg_UnitIndexEvent", EQUAL, 1.00 )
    call TriggerRegisterVariableEvent( gg_trg_DecoBuilder_Increase_Count, "udg_DeathEvent", EQUAL, 2.00 )
    call TriggerAddCondition( gg_trg_DecoBuilder_Increase_Count, Condition( function Trig_DecoBuilder_Increase_Count_Conditions ) )
endfunction

