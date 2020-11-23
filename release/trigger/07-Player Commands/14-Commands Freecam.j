scope CommandsFreeCam

private function onCommand takes nothing returns boolean
    local boolean enable = not FreeCam_IsEnabled(GetTriggerPlayer())
        
    call FreeCam_Enable(GetTriggerPlayer(), enable)
    
    return false
endfunction
//===========================================================================
function InitTrig_Commands_Freecam takes nothing returns nothing
    call LoP_Command.create("-freecam", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
