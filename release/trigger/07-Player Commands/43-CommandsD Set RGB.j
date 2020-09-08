function ColorSystem_Set_RGB_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local string command = LoP_Command.getCommand()
    local string output
    local integer pN = GetPlayerId(GetTriggerPlayer())+1
    local integer red
    local integer green
    local integer blue
    local integer alpha
    
    if command == "-rgb" then
        set red = CutToCharacter(args," ")
        set output = SubString(args,0,red)
        set udg_ColorSystem_Red[pN] = S2R(output)
        
        set args = SubString( args , red+1 , StringLength(args) )
        set green = CutToCharacter(args," ")
        set output = SubString(args,0,green)
        set udg_ColorSystem_Green[pN] = S2R(output)

        set args = SubString(args,green+1, StringLength(args))
        set blue = CutToCharacter(args," ")
        set output = SubString(args,0,blue)
        set udg_ColorSystem_Blue[pN] = S2R(output)

        set args = SubString(args,blue+1, StringLength(args))
        set alpha = CutToCharacter(args," ")
        set output = SubString(args,0,alpha)
        set udg_ColorSystem_Alpha[pN] = S2R(output)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default RGBT has been set.")
        
    elseif command == "-red" then
        set udg_ColorSystem_Red[pN]   = Arguments_ParseNumber(args)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cffff0000Red|r tint has been set.")
        
    elseif command == "-green" then
        set udg_ColorSystem_Green[pN] = Arguments_ParseNumber(args)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cff00ff00Green|r tint has been set.")
        
    elseif command == "-blue" then
        set udg_ColorSystem_Blue[pN]  = Arguments_ParseNumber(args)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default |cff0000ffBlue|r has been set.")
        
    elseif command == "-alpha" then
        set udg_ColorSystem_Alpha[pN] = Arguments_ParseNumber(args)
        call LoP_WarnPlayer(GetTriggerPlayer(), LoPChannels.SYSTEM, "Default Transparency has been set.")
        
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Set_RGB takes nothing returns nothing
    call LoP_Command.create("-rgb", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-red", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-green", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-blue", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
    call LoP_Command.create("-alpha", ACCESS_USER, Condition(function ColorSystem_Set_RGB_Conditions))
endfunction

