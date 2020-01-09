function Trig_CommandsR_Mind_Conditions takes nothing returns boolean
    call DisplayTextToPlayer(GetTriggerPlayer(), 0, 0, "This command has been depracated. Use |cffffff00-give|r and |cffffff00-give all|r instead.")
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Mind takes nothing returns nothing
    call LoP_Command.create("-mind", ACCESS_TITAN, Condition(function Trig_CommandsR_Mind_Conditions))
    call LoP_Command.create("'mind", ACCESS_TITAN, Condition(function Trig_CommandsR_Mind_Conditions))
endfunction

