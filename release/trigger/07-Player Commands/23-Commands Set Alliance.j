function LoP_SetAllianceState takes player whichPlayer, player other, integer allianceState returns nothing
    if allianceState == -1 then
        call LoP_PlayerData.get(whichPlayer).setAtWar(other, true)
    elseif allianceState == -2 then
        call LoP_PlayerData.get(whichPlayer).setAtWar(other, false)
    else
        call SetPlayerAllianceStateBJ( whichPlayer, other,  allianceState)
    endif
endfunction

function Trig_Commands_SetAlliance_Conditions takes nothing returns boolean
    local integer i
    local integer allianceState
    local string command = LoP_Command.getCommand()
    local string arguments = LoP_Command.getArguments()
    local integer cutToComma
    local player sourcePlayer = GetTriggerPlayer()
    
    
    if sourcePlayer == udg_GAME_MASTER and (S2I(arguments) != 0 or Commands_GetChatMessagePlayerNumber(arguments) == 0) then
        set cutToComma = CutToCharacter(arguments, " ")
        if cutToComma < StringLength(arguments) then
            set sourcePlayer = Player(Commands_GetChatMessagePlayerNumber(SubString(arguments, 0, cutToComma)) - 1)
            set arguments = SubString(arguments, cutToComma+1, StringLength(arguments))
        endif
    endif
      
    if command == "-ally" then
        set allianceState = bj_ALLIANCE_ALLIED_VISION
    elseif command == "-unally" then
        set allianceState = bj_ALLIANCE_UNALLIED
    elseif command == "-share" then
        set allianceState = bj_ALLIANCE_ALLIED_ADVUNITS
    elseif command == "-war" then
        set allianceState = -1
    elseif command == "-unwar" then
        set allianceState = -2
    endif
    
    if ( arguments == "all" ) then
        set i = 0
        loop
        exitwhen i >= bj_MAX_PLAYERS
            call LoP_SetAllianceState(sourcePlayer, Player(i),  allianceState)
            set i = i + 1
        endloop
    else
        set i = Commands_GetChatMessagePlayerNumber(arguments)
        if PlayerNumberIsNotNeutral(i) then
            call LoP_SetAllianceState(sourcePlayer, ConvertedPlayer(i),  allianceState)
        endif
    endif
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

