function Trig_CommandsR_Kick_Conditions takes nothing returns boolean
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    
    if  PlayerNumberIsNotNeutral(playerNumber) then
        call CustomDefeatBJ( Player(playerNumber-1), "You were kicked!" )
    endif
    
    call LoP_WarnPlayer(User.Local, LoPChannels.WARNING, "Player " + I2S(playerNumber) + " was kicked.")
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Kick takes nothing returns nothing
    call LoP_Command.create("-kick", ACCESS_TITAN, Condition(function Trig_CommandsR_Kick_Conditions))
endfunction

