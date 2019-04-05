function Trig_CommandsD_Set_Parameters_Actions takes nothing returns nothing
    local string command = GetEventPlayerChatStringMatched()
    local player trigPlayer = GetTriggerPlayer()
    local integer playerNumber = GetPlayerId(trigPlayer) + 1
    local string args = Commands_GetArguments()
    
    if command == "-size " then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Size Set" )
        set udg_DecoSystem_Scale[playerNumber] = RMinBJ(S2R(args), 2000.)
    elseif command == "-face " then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Facing Set" )
        set udg_DecoSystem_Facing[playerNumber] = S2R(args)
    elseif command == "-fly " then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Fly Height Set" )
        set udg_DecoSystem_Height[playerNumber] = RMinBJ(S2R(args), 10000.)
    elseif command == "-anim " then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Animation Set" )
        set udg_DecoSystem_Anims[playerNumber] = args
    elseif command == "-speed " then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Animation Speed Set" )
        set udg_DecoSystem_animSpeed[playerNumber] = RMinBJ(S2R(args), 2000.)
    elseif command == "-grid " then
        set udg_System_DecoGrid[playerNumber] = S2R(args)
    elseif command == "-color " then
        set udg_DecoSystem_PlayerColor[playerNumber] = Commands_GetChatMessagePlayerNumber(args)
    endif
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_Parameters takes nothing returns nothing
    set gg_trg_CommandsD_Set_Parameters = CreateTrigger(  )
    call TriggerAddAction( gg_trg_CommandsD_Set_Parameters, function Trig_CommandsD_Set_Parameters_Actions )
endfunction

