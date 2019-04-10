function Trig_CommandsR_Enable_Dmg_Tags_Conditions takes nothing returns boolean
    if LoP_Command.getArguments() == "tags" then
        set ENABLE_TAGS = not ENABLE_TAGS
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Toggle_Dmg_Tags takes nothing returns nothing
    call LoP_Command.create("-combat", ACCESS_TITAN, Condition(function Trig_CommandsR_Enable_Dmg_Tags_Conditions))
endfunction

