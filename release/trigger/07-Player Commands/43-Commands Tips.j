scope CommandsTips

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    
    if args == "on" then
        set LoPTip_enabled = true
    elseif args == "off" then
        set LoPTip_enabled = false
    elseif args == "" then
        set LoPTip_enabled = not LoPTip_enabled
    endif
        
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Tips takes nothing returns nothing
    call LoP_Command.create("-tips", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
