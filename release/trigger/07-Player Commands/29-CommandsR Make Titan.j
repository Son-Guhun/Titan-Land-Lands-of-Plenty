scope CommandMakeTitan

private function OnCommand takes nothing returns boolean
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    local player trigP = GetTriggerPlayer()
    
    if PlayerNumberIsNotNeutral(playerNumber) and (trigP == udg_GAME_MASTER or trigP == Player(0)) then
    
        if GetPlayerSlotState(Player(playerNumber - 1)) == PLAYER_SLOT_STATE_PLAYING then
            call MakeTitan(Player(playerNumber - 1))
        else
            call DisplayTextToPlayer(trigP, 0., 0., "There's no player in that slot!" )
        endif
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Make_Titan takes nothing returns nothing
    call LoP_Command.create("-titan", ACCESS_USER, Condition(function OnCommand))
endfunction

endscope
