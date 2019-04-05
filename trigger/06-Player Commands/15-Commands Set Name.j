function Trig_Commands_Set_Name_Actions takes nothing returns nothing
    if Commands_StartsWithCommand() then
        call SetPlayerName(GetTriggerPlayer(), Commands_GetArguments())
    endif
endfunction

//===========================================================================
function InitTrig_Commands_Set_Name takes nothing returns nothing
    set gg_trg_Commands_Set_Name = CreateTrigger()
    call TriggerAddAction( gg_trg_Commands_Set_Name, function Trig_Commands_Set_Name_Actions )
endfunction

