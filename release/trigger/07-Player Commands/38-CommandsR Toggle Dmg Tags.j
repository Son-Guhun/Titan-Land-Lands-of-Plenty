function Trig_CommandsR_Enable_Dmg_Tags_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()

    if args == "tags" then
        set ENABLE_TAGS = not ENABLE_TAGS
    elseif args == "tags on" then
        set ENABLE_TAGS = true
    elseif args == "tags off" then
        set ENABLE_TAGS = false
    endif
    
    if ENABLE_TAGS then
        call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, "Combat floating tags enabled.")
    else
        call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, "Combat floating tags disabled.")
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Toggle_Dmg_Tags takes nothing returns nothing
    call LoP_Command.create("-combat", ACCESS_TITAN, Condition(function Trig_CommandsR_Enable_Dmg_Tags_Conditions))
endfunction

