scope CommandsSetAlliance

globals
    private constant integer ALL = - 1
    
    private constant integer ALLIANCE_WAR = -1
    private constant integer ALLIANCE_UNWAR = -2
endglobals

function LoP_SetAllianceState takes player whichPlayer, player other, integer allianceState returns nothing
    if allianceState == ALLIANCE_WAR then
        call LoP_PlayerData.get(whichPlayer).setAtWar(other, true)
    elseif allianceState == ALLIANCE_UNWAR then
        call LoP_PlayerData.get(whichPlayer).setAtWar(other, false)
    else
        call SetPlayerAllianceStateBJ( whichPlayer, other,  allianceState)
    endif
endfunction

private function PlayerName takes integer playerNumber returns string
    return "Player " + I2S(playerNumber)
    // return LoP_PlayerData(playerNumber-1).realName
endfunction

function Trig_Commands_SetAlliance_Conditions takes nothing returns boolean
    local integer i
    local integer allianceState
    local string command = LoP_Command.getCommand()
    local ArrayList_string args = StringSplitWS(LoP_Command.getArgumentsRaw())
    local integer cutToComma
    local player sourcePlayer = GetTriggerPlayer()
    local integer p1 = GetNextPlayerArgument(args)
    local integer p2 = GetNextPlayerArgument(args)
    local string channel = LoPChannels.SYSTEM
    
    if p1 == 0  then
        call LoP_WarnPlayer(sourcePlayer, LoPChannels.ERROR, "Could not convert arguments to a valid player ID.")
        
    elseif p1 != ALL and not PlayerNumberIsNotNeutral(p1) then
        call LoP_WarnPlayer(sourcePlayer, LoPChannels.ERROR, "Cannot perform this action with neutral players.")
        
    else
        if p1 != ALL and sourcePlayer == udg_GAME_MASTER and (PlayerNumberIsNotNeutral(p2) or p2 == ALL) then
            if p2 == ALL then
                call LoP_WarnPlayer(sourcePlayer, LoPChannels.SYSTEM, "Performing (" + command + ") for " + UserColor(p1-1).hex + PlayerName(p1) + "|r, targeting all players.")
            else
                call LoP_WarnPlayer(sourcePlayer, LoPChannels.SYSTEM, "Performing (" + command + ") for " + UserColor(p1-1).hex + PlayerName(p1) + "|r, targeting " + UserColor(p2-1).hex + PlayerName(p2) + "|r.")
            endif
            
            set sourcePlayer = Player(p1 - 1)
            set p1 = p2
            set channel = LoPChannels.WARNING  // Send message as warning to sourcePlayer if the Titan forced the alliance state.
        endif
        
        if command == "-ally" then
            set allianceState = bj_ALLIANCE_ALLIED_VISION
        elseif command == "-unally" then
            set allianceState = bj_ALLIANCE_UNALLIED
        elseif command == "-share" then
            set allianceState = bj_ALLIANCE_ALLIED_ADVUNITS
        elseif command == "-war" then
            set allianceState = ALLIANCE_WAR
        elseif command == "-unwar" then
            set allianceState = ALLIANCE_UNWAR
        endif
        
        if ( p1 == ALL ) then
            set i = 0
            loop
            exitwhen i >= bj_MAX_PLAYERS
                call LoP_SetAllianceState(sourcePlayer, Player(i),  allianceState)
                set i = i + 1
            endloop
            call LoP_WarnPlayer(sourcePlayer, channel, "Performing (" + command + ") with all players.")
        else
            call LoP_WarnPlayer(sourcePlayer, channel, "Performing (" + command + ") with " + UserColor(p1-1).hex + PlayerName(p1) + "|r.")
            call LoP_SetAllianceState(sourcePlayer, ConvertedPlayer(p1),  allianceState)
        endif
    endif
    
    call args.destroy()
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Set_Alliance takes nothing returns nothing
    call LoP_Command.create("-ally", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions))/*
    */.createChained("-unally", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions)) /*
    */.createChained("-share", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions)) /*
    */.createChained("-war", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions)) /*
    */.createChained("-unwar", ACCESS_USER, Condition(function Trig_Commands_SetAlliance_Conditions))
endfunction

endscope
