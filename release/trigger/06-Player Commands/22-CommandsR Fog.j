function Trig_CommandsR_Fog_Conditions takes nothing returns boolean
    local string chatStr = Commands_GetArguments()
    local integer style
    local real zStart
    local real zEnd
    local real red
    local real green
    local real blue
    local real density
    local integer cutToComma
    
    if GetTriggerPlayer() != udg_GAME_MASTER and not Commands_StartsWithCommand() then
        return false
    endif
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set style = S2I(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set zStart = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set zEnd = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set red = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set green = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set cutToComma = CutToCharacter(chatStr, " ")
    set blue = S2R(CutToCommaResult(chatStr, cutToComma))
    set chatStr = CutToCommaShorten(chatStr, cutToComma)
    
    set density = S2R(SubString(chatStr,0,StringLength(chatStr) + 1))
    
    call SetTerrainFogExBJ( style, zStart, zEnd, density, red, green, blue )
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Fog takes nothing returns nothing
    set gg_trg_CommandsR_Fog = CreateTrigger(  )
    call TriggerAddCondition( gg_trg_CommandsR_Fog, Condition( function Trig_CommandsR_Fog_Conditions ) )
endfunction

