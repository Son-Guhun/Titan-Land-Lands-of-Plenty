function Trig_CommandsR_Fog_Conditions takes nothing returns boolean
    local string chatStr = LoP_Command.getArguments()
    local ArrayList_string args
    
    static if LIBRARY_AutoRectEnvironment then
        local TerrainFog fog
    
        if chatStr == "reset" then
            set RectEnvironment.default.fog = 0
            return false
        endif
        
        set args = StringSplitWS(chatStr)
        set fog = RectEnvironment.default.fog
        
        if fog == 0 then
            set fog = TerrainFog.create()
            set RectEnvironment.default.fog = fog
        endif
        
        set fog.style   = S2I(args[0])
        set fog.zStart  = S2R(args[1])
        set fog.zEnd    = S2R(args[2])
        set fog.density = S2R(args[3]) * 0.01
        set fog.red     = S2R(args[4]) * 0.01
        set fog.green   = S2R(args[5]) * 0.01
        set fog.blue    = S2R(args[6]) * 0.01
    else
        if chatStr == "reset" then
            call ResetTerrainFog()
            return false
        endif
    
        set args = StringSplitWS(chatStr)
        call SetTerrainFogExBJ( S2I(args[0]), S2R(args[1]), S2R(args[2]), S2R(args[3]), S2R(args[4]), S2R(args[5]), S2R(args[6]))
    endif
    
    call args.destroy()
    return false
endfunction

//===========================================================================
function InitTrig_CommandsR_Fog takes nothing returns nothing
    call LoP_Command.create("-fog", ACCESS_TITAN, Condition(function Trig_CommandsR_Fog_Conditions))
endfunction

