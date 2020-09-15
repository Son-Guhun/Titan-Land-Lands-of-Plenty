function ColorSystem_Set_RGB_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local string command = LoP_Command.getCommand()
    local integer pN = GetPlayerId(GetTriggerPlayer())+1
    
    if command == "-rgb" then
        call Commands_SetRGBAFromString(GetTriggerPlayer(), args, false)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default RGBT has been set.")
    elseif command == "-rgbi" then
        call Commands_SetRGBAFromString(GetTriggerPlayer(), args, true)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default RGBT has been set.")
    
    elseif command == "-rgbh" then
        call Commands_SetRGBAFromHex(GetTriggerPlayer(), args)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default RGBT has been set.")
    
    elseif command == "-red" then
        set udg_ColorSystem_Red[pN]   = R2I(2.55*Arguments_ParseNumber(args) + 0.5)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cffff0000Red|r tint has been set.")
        
    elseif command == "-green" then
        set udg_ColorSystem_Green[pN] = R2I(2.55*Arguments_ParseNumber(args) + 0.5)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cff00ff00Green|r tint has been set.")
        
    elseif command == "-blue" then
        set udg_ColorSystem_Blue[pN]  = R2I(2.55*Arguments_ParseNumber(args) + 0.5)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cff0000ffBlue|r has been set.")
        
    elseif command == "-alpha" then
        set udg_ColorSystem_Alpha[pN] = R2I(2.55*(100. - Arguments_ParseNumber(args)) + 0.5)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default Transparency has been set.")
        
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_RGB takes nothing returns nothing
    call LoP_Command.create("-rgb", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-rgbi", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-rgbh", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-red", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-green", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-blue", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-alpha", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
endfunction

