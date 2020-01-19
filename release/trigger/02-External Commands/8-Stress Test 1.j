function Trig_Untitled_Trigger_001_Actions takes nothing returns nothing
    local integer i = 0
    local unit u
    loop
        exitwhen i >= 50
        set u = CreateUnit(Player(0), 'e001', 0., 0., bj_UNIT_FACING)
        call IssueImmediateOrderById(u, 'e00V')
        call RemoveUnit(u)
        set i = i + 1
    endloop
    set u = null
endfunction

//===========================================================================
function InitTrig_Stress_Test_1 takes nothing returns nothing
    set gg_trg_Stress_Test_1 = CreateTrigger(  )
    call TriggerRegisterTimerEventPeriodic( gg_trg_Stress_Test_1, 0.50)
    call TriggerRegisterPlayerChatEvent(gg_trg_Stress_Test_1, Player(0), "a", true)
    call TriggerAddAction( gg_trg_Stress_Test_1, function Trig_Untitled_Trigger_001_Actions )
endfunction

