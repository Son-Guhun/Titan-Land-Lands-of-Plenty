function ColorSystem_Set_RGB_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local string command = LoP_Command.getCommand()
    local integer pN = GetPlayerId(GetTriggerPlayer())+1
    local RGBA color = udg_DecoSystem_RGBA[pN]
    
    if command == "-rgb" then
        set color = Commands_SetRGBAFromString(GetTriggerPlayer(), args, false)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default RGBT has been set.")
        
    elseif command == "-rgbi" then
        set color = Commands_SetRGBAFromString(GetTriggerPlayer(), args, true)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default RGBT has been set.")
    
    elseif command == "-rgbh" then
        set color = Commands_SetRGBAFromHex(GetTriggerPlayer(), args)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default RGBT has been set.")
    
    elseif command == "-red" then
        set color = color.withRed(R2I(2.55*Arguments_ParseNumber(args) + 0.5))
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cffff0000Red|r tint has been set.")
        
    elseif command == "-green" then
        set color = color.withGreen(R2I(2.55*Arguments_ParseNumber(args) + 0.5))
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cff00ff00Green|r tint has been set.")
        
    elseif command == "-blue" then
        set color = color.withBlue(R2I(2.55*Arguments_ParseNumber(args) + 0.5))
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cff0000ffBlue|r has been set.")
        
    elseif command == "-alpha" then
        set color = color.withAlpha(R2I(2.55*(100. - Arguments_ParseNumber(args)) + 0.5)) 
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default Transparency has been set.")
    
    endif
    
    set udg_DecoSystem_RGBA[pN]   = color
    
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_RGB takes nothing returns nothing
    call LoP_Command.create("-rgb", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))/*
    */.createChained("-rgbi", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions)) /*
    */.createChained("-rgbh", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions)) /*
    */.createChained("-red", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions)) /*
    */.createChained("-green", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions)) /*
    */.createChained("-blue", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions)) /*
    */.createChained("-alpha", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
endfunction

