function Trig_CommandsR_Toggle_Prot_Conditions takes nothing returns boolean
    if LoP_Command.getArguments() == "protection" then
        if ( IsTriggerEnabled(gg_trg_System_Titan_Palace_Prot) ) then
            call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, "Inner Titan Palace Protection Disabled." )
            call DisableTrigger( gg_trg_System_Titan_Palace_Prot )
            call DisableTrigger( gg_trg_System_Titan_Palace_Item_Prot )
        else
            call LoP_WarnPlayer(User.Local, LoPChannels.SYSTEM, "Inner Titan Palace Protection Enabled." )
            call EnableTrigger( gg_trg_System_Titan_Palace_Prot )
            call EnableTrigger( gg_trg_System_Titan_Palace_Item_Prot )
        endif
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Toggle_Prot takes nothing returns nothing
    call LoP_Command.create("-palace", ACCESS_TITAN, Condition(function Trig_CommandsR_Toggle_Prot_Conditions))
endfunction

