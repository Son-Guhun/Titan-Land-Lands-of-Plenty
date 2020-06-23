function Trig_System_Detect_Leaver_Actions takes nothing returns nothing
    call LoP_SendSysMsg(User.Local, GetPlayerName(GetTriggerPlayer()) + " has left the game.")
    
    if GetTriggerPlayer() == udg_GAME_MASTER then
        call MakeTitan(FindFirstPlayer())
        call LoP_SendSysMsg(User.Local, "The Titan has left. " + GetPlayerName(udg_GAME_MASTER) + " is the new Titan.")
    endif
endfunction

//===========================================================================
function InitTrig_System_Detect_Leaver takes nothing returns nothing
    set gg_trg_System_Detect_Leaver = CreateTrigger()
    call TriggerAddAction( gg_trg_System_Detect_Leaver, function Trig_System_Detect_Leaver_Actions )
endfunction

