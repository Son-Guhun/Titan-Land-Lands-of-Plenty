function Trig_CommandsR_Time_Conditions takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local integer cutToComma = CutToCharacter(args, ":")
    local integer size = StringLength(args)
    local real value = 0
    local string finalChars = StringCase(SubString(args, size-2, size), false)
    
    if finalChars == "pm" then
        set value = 12
        set args = SubString(args, 0, size-2)
    elseif finalChars == "am" then
        set args = SubString(args, 0, size-2)
    endif
    
    if cutToComma < StringLength(args) /* use StringLength since str may have changed */ then
        set value = value + S2I(SubString(args,0,cutToComma)) + S2I(SubString(args,cutToComma+1,StringLength(args)))/60.
    else
        set value = value + S2R(args)
    endif
    
    call SetFloatGameState(GAME_STATE_TIME_OF_DAY, value)
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Time takes nothing returns nothing
    call LoP_Command.create("-time", ACCESS_TITAN, Condition(function Trig_CommandsR_Time_Conditions))
endfunction
