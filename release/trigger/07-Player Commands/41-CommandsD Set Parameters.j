function Trig_CommandsD_Set_Parameters_Conditions takes nothing returns boolean
    local string command = LoP_Command.getCommand()
    local player trigPlayer = GetTriggerPlayer()
    local integer playerNumber = GetPlayerId(trigPlayer) + 1
    local string args = LoP_Command.getArguments()
    
    if command == "-size" then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Size Set" )
        set udg_DecoSystem_Scale[playerNumber] = args
    elseif command == "-face" or command == "-f" then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Facing Set" )
        set udg_DecoSystem_Facing[playerNumber] = MathParser.calculate(args)
    elseif command == "-fly" or command == "-h" then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Fly Height Set" )
        set udg_DecoSystem_Height[playerNumber] = RMinBJ(MathParser.calculate(args), 10000.)
    elseif command == "-anim" then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Animation Set" )
        set udg_DecoSystem_Anims[playerNumber] = args
    elseif command == "-speed" then
        call DisplayTextToPlayer(trigPlayer, 0, 0, "Animation Speed Set" )
        set udg_DecoSystem_animSpeed[playerNumber] = RMinBJ(MathParser.calculate(args), 2000.)
    elseif command == "-grid" then
        set udg_System_DecoGrid[playerNumber] = MathParser.calculate(args)
    elseif command == "-color" then
        set udg_DecoSystem_PlayerColor[playerNumber] = Commands_GetChatMessagePlayerNumber(args)
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_Parameters takes nothing returns nothing
    call LoP_Command.create("-size", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-face", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-f", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-fly", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-h", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-anim", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-speed", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-grid", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
    call LoP_Command.create("-color", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
endfunction

