scope CommandsFreeCam

private function onCommand takes nothing returns boolean    
    if FreeCam_IsEnabled(GetTriggerPlayer()) then       
        call FreeCam_Enable(GetTriggerPlayer(), false)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Free Camera Disabled.")
    else
        call FreeCam_Enable(GetTriggerPlayer(), true)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Free Camera Enabled.")
    endif
    
    return false
endfunction
//===========================================================================
function InitTrig_Commands_Freecam takes nothing returns nothing
    call LoP_Command.create("-freecam", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
