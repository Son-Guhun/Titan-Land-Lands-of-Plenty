function Trig_CommandsR_Water_Color_Conditions takes nothing returns boolean
    local string chatStr = Commands_GetArguments()
    local real red
    local real green
    local real blue
    local real trans
    local integer cutToComma
    
    if GetTriggerPlayer() != udg_GAME_MASTER and not Commands_StartsWithCommand() then
        return false
    endif
    
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
    set gg_trg_CommandsR_Water_Color = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_CommandsR_Water_Color, Condition( function Trig_CommandsR_Water_Color_Conditions ) )
endfunction

