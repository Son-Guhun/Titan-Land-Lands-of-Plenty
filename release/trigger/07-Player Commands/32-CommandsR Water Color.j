// -water red,green,blue,alpha
function Trig_CommandsR_Water_Color_Conditions takes nothing returns boolean
    local string chatStr = LoP_Command.getArguments()
    local ArrayList_string args
    
    set args = StringSplitWS(chatStr)
    
    call SetWaterBaseColorBJ(S2R(args[0]), S2R(args[1]), S2R(args[2]), S2R(args[3]))
    
    call args.destroy()
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Water_Color takes nothing returns nothing
    call LoP_Command.create("-water", ACCESS_TITAN, Condition(function Trig_CommandsR_Water_Color_Conditions))
endfunction

