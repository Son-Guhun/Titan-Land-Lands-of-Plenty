function Trig_CommandsR_Fog_Conditions takes nothing returns boolean
    local string chatStr = LoP_Command.getArguments()
    local integer style
    local real zStart
    local real zEnd
    local real density
    local real red
    local real green
    local real blue
    local integer cutToComma
    
    static if LIBRARY_AutoRectEnvironment then
        local TerrainFog fog
    endif
    
    if chatStr == "reset" then
        call RectEnvironment(0).fog.destroy()
        set RectEnvironment(0).fog = 0
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
    set density = S2R(CutToCommaResult(chatStr, cutToComma))
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
    
    static if LIBRARY_AutoRectEnvironment then
        set fog = RectEnvironment(0).fog
        
        if fog == 0 then
            set fog = TerrainFog.create()
            set RectEnvironment(0).fog = fog
        endif
        
        set fog.style = style
        set fog.zStart = zStart
        set fog.zEnd = zEnd
        set fog.density = density * 0.01
        set fog.red = red * 0.01
        set fog.green = green * 0.01
        set fog.blue = blue * 0.01
    else
        call SetTerrainFogExBJ( style, zStart, zEnd, density, red, green, blue )
    endif
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Fog takes nothing returns nothing
    call LoP_Command.create("-fog", ACCESS_TITAN, Condition(function Trig_CommandsR_Fog_Conditions))
endfunction

