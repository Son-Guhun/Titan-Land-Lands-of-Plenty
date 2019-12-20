scope CommandsFix

private function OnCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    
    if args == "darkness" then
        call ResetTerrainFog()
        call SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
    elseif args == "selection" then
        call BlzFrameSetFocus(BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), true)
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Fix takes nothing returns nothing
    call LoP_Command.create("-fix", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope
