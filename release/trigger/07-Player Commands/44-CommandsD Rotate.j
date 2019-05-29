function Trig_CommandsD_Rotate_Conditions takes nothing returns boolean
    local string args = I2S(S2I(LoP_Command.getArguments()))  // Double convert to guarantee int in tooltips
    set LoP_PlayerData.get(GetTriggerPlayer()).rotationStep = S2I(args)
    
    if GetLocalPlayer() == GetTriggerPlayer() then
        call BlzSetAbilityTooltip('A011', "Rotate " + args + " Degrees- [|cffffcc00R|r]", 1)
        call BlzSetAbilityExtendedTooltip('A011', "Makes this unit face an angle equal to the smallest multiple of " + args + " that is larger than its current angle. For structures (likes gates and walls), their pathing block will only be updated if they are rotate to either 0 degrees or 180 degrees. Any other angle will use the default angle (270 degrees) pathing block.", 1)
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsD_Rotate takes nothing returns nothing
    call LoP_Command.create("-rotate", ACCESS_USER, Condition(function Trig_CommandsD_Rotate_Conditions ))
endfunction
