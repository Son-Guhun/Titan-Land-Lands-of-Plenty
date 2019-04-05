function Trig_CommandsR_Kick_Conditions takes nothing returns boolean
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(Commands_GetArguments())
    
    if Commands_StartsWithCommand() and GetTriggerPlayer() == udg_GAME_MASTER then
        if  PlayerNumberIsNotNeutral(playerNumber) then
            call CustomDefeatBJ( ConvertedPlayer(playerNumber), "You were kicked!" )
        endif
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Kick takes nothing returns nothing
    set gg_trg_CommandsR_Kick = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_CommandsR_Kick, Condition( function Trig_CommandsR_Kick_Conditions ) )
endfunction

