function Trig_CommandsR_Water_Color_Conditions takes nothing returns boolean
    local string chatStr = LoP_Command.getArguments()
    local real red
    local real green
    local real blue
    local real trans
    local integer cutToComma
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set red = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set green = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set blue = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set trans = S2R(SubString(chatStr,0,StringLength(chatStr) + 1))
    
    call SetWaterBaseColorBJ( red, green, blue, trans )
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Water_Color takes nothing returns nothing
    call LoP_Command.create("-water", ACCESS_TITAN, Condition(function Trig_CommandsR_Water_Color_Conditions))
endfunction

