scope CommandsRoll 

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    local integer cutToComma
    local integer diceMin
    local integer diceMax
    local integer diceNumber
    local integer diceBonus
    local integer i = 0
    local integer result = 0
    local integer random
    
    set cutToComma = CutToCharacter(args, "d")
    if cutToComma < StringLength(args) then
        set diceMin = 1
        set diceNumber = S2I(SubString(args, 0, cutToComma))
        set args = SubString(args, cutToComma+1, StringLength(args))
        set cutToComma = CutToCharacter(args, "+")
        if cutToComma < StringLength(args) then
            set diceBonus = 1
        else
            set cutToComma = CutToCharacter(args, "-")
            set diceBonus = -1
        endif
        set diceMax = S2I(SubString(args, 0, cutToComma))
        if cutToComma < StringLength(args) then
            set diceBonus = S2I(SubString(args, cutToComma+1, StringLength(args))) * diceBonus
        else
            set diceBonus = 0
        endif
    else
        set diceBonus = 0
        set cutToComma = CutToCharacter(args, " ")
        set diceMin = S2I(SubString(args, 0, cutToComma))
        set args = SubString(args, cutToComma+1, StringLength(args))
        set cutToComma = CutToCharacter(args, " ")
        set diceMax = S2I(SubString(args, 0, cutToComma))
        if cutToComma < StringLength(args) then
            set diceNumber = diceMin
            set diceMin = diceMax
            set diceMax = S2I(SubString(args, cutToComma+1, StringLength(args)))
        else
            set diceNumber = 1
        endif
    endif
    
    debug call BJDebugMsg(I2S(diceNumber))
    debug call BJDebugMsg(I2S(diceMin))
    debug call BJDebugMsg(I2S(diceMax))
    debug call BJDebugMsg(I2S(diceBonus))
    
    loop
    exitwhen i >= diceNumber
        set random = GetRandomInt(diceMin, diceMax)
        if diceNumber > 1 and i < 5 then
            call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., GetPlayerName(GetTriggerPlayer()) + " die result " + I2S(i+1) + ": " + I2S(random))
        endif
        set result = result + random
        set i = i + 1
    endloop
    set result = result + diceBonus
    call DisplayTextToPlayer(GetLocalPlayer(), 0., 0., GetPlayerName(GetTriggerPlayer()) + " has rolled " + I2S(result))
        
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Roll takes nothing returns nothing
    call LoP_Command.create("-roll", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
