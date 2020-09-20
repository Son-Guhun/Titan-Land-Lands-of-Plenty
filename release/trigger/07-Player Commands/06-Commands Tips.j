scope CommandsTips

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local string enabled = "Tips enabled."
    local string disabled = "Tips disabled."
    local player trigP = GetTriggerPlayer()
    
    if args == "on" then
        if User.Local == trigP then
            set LoPTip_enabled = true
        endif
    elseif args == "off" then
        if User.Local == trigP then
            set LoPTip_enabled = false
        endif
    elseif args == "" then
        if User.Local == trigP then
            set LoPTip_enabled = not LoPTip_enabled
        endif
    endif
    
    if LoPTip_enabled then
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, enabled)
    else
        call LoP_WarnPlayer(trigP, LoPChannels.SYSTEM, disabled)
    endif
        
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Tips takes nothing returns nothing
    call LoP_Command.create("-tips",  ACCESS_USER, Condition(function onCommand )) /*
    */.createChained("-hints", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
