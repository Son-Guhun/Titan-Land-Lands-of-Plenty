function Trig_CommandsD_Set_Parameters_Conditions takes nothing returns boolean
    local string command = LoP_Command.getCommand()
    local player trigPlayer = GetTriggerPlayer()
    local integer playerNumber = GetPlayerId(trigPlayer) + 1
    local string args = LoP_Command.getArguments()
    
    if command == "-size" then
        call LoP_WarnPlayer(trigPlayer, LoPChannels.SYSTEM, "Default Size set." )
        set udg_DecoSystem_Scale[playerNumber] = args
    elseif command == "-face" or command == "-f" then
        call LoP_WarnPlayer(trigPlayer, LoPChannels.SYSTEM, "Default Facing set." )
        set udg_DecoSystem_Facing[playerNumber] = MathParser.calculate(args)
    elseif command == "-fly" or command == "-h" then
        call LoP_WarnPlayer(trigPlayer, LoPChannels.SYSTEM, "Default Flying Height set." )
        set udg_DecoSystem_Height[playerNumber] = RMinBJ(MathParser.calculate(args), 10000.)
    elseif command == "-anim" then
        call LoP_WarnPlayer(trigPlayer, LoPChannels.SYSTEM, "Default Animation set." )
        set udg_DecoSystem_Anims[playerNumber] = args
    elseif command == "-speed" then
        call LoP_WarnPlayer(trigPlayer, LoPChannels.SYSTEM, "Default Animation Speed set." )
        set udg_DecoSystem_animSpeed[playerNumber] = RMinBJ(MathParser.calculate(args), 2000.)
    elseif command == "-grid" then
        call LoP_WarnPlayer(trigPlayer, LoPChannels.SYSTEM, "Grid Size set." )
        set udg_System_DecoGrid[playerNumber] = MathParser.calculate(args)
    elseif command == "-color" then
        call LoP_WarnPlayer(trigPlayer, LoPChannels.SYSTEM, "Default Color set." )
        set udg_DecoSystem_PlayerColor[playerNumber] = Commands_GetChatMessagePlayerNumber(args)
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_Parameters takes nothing returns nothing
    call LoP_Command.create("-size", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))/*
    */.createChained("-face", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions)) /*
    */.createChained("-f", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions)) /*
    */.createChained("-fly", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions)) /*
    */.createChained("-h", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions)) /*
    */.createChained("-anim", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions)) /*
    */.createChained("-speed", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions)) /*
    */.createChained("-grid", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions)) /*
    */.createChained("-color", ACCESS_USER, Condition(function Trig_CommandsD_Set_Parameters_Conditions))
endfunction

