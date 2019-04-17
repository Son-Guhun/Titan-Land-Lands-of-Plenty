function Trig_CommandsR_Time_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local integer cutToComma = CutToCharacter(args, ":")
    local real value
    
    if cutToComma < StringLength(args) then
        set value = S2I(SubString(args,0,cutToComma)) + S2I(SubString(args,cutToComma+1,StringLength(args)))/60.
    else
        set value = S2R(args)
    endif
    
    debug call BJDebugMsg("Set time of day to: " + R2S(value))
    
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, value)
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Time takes nothing returns nothing
    call LoP_Command.create("-time", ACCESS_TITAN, Condition(function Trig_CommandsR_Time_Conditions))
endfunction

