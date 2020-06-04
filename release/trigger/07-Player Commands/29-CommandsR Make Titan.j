scope CommandMakeTitan

private function OnCommand takes nothing returns boolean
    local integer playerNumber = Commands_GetChatMessagePlayerNumber(LoP_Command.getArguments())
    local player trigP = GetTriggerPlayer()
    
    if PlayerNumberIsNotNeutral(playerNumber) and (trigP == udg_GAME_MASTER or trigP == Player(0)) then
        set udg_GAME_MASTER = ConvertedPlayer(playerNumber)
        
        if GetPlayerSlotState(udg_GAME_MASTER) == PLAYER_SLOT_STATE_PLAYING then
        
            call SetUnitOwner(HERO_COSMOSIS(), udg_GAME_MASTER, false)
            if GetOwningPlayer(HERO_CREATOR()) != Player(PLAYER_NEUTRAL_PASSIVE) then
                call SetUnitOwner(HERO_CREATOR(), udg_GAME_MASTER, false)
            endif
            
            call SetUnitOwner(POWER_REMOVE(), udg_GAME_MASTER, false)
            call SetUnitOwner(POWER_KILL(), udg_GAME_MASTER, false)
            call SetUnitOwner(POWER_DELEVEL(), udg_GAME_MASTER, false)
            call SetUnitOwner(POWER_LEVEL(), udg_GAME_MASTER, false)
            call SetUnitOwner(POWER_INVULNERABILITY(), udg_GAME_MASTER, false)
            call SetUnitOwner(POWER_VULNERABILITY(), udg_GAME_MASTER, false)
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
