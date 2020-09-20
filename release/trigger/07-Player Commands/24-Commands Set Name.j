function Trig_Commands_Set_Name_Conditions takes nothing returns boolean
    call SetPlayerName(GetTriggerPlayer(), LoP_Command.getArguments())
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Set_Name takes nothing returns nothing
    call LoP_Command.create("-name", ACCESS_USER, Condition(function Trig_Commands_Set_Name_Conditions)).addHint(LoPHints.COMMAND_NAMEUNIT)
endfunction

