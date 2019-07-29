scope CommandsFix

private function OnCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    
    if args == "selection" then
        call BlzEnableSelections(true, true)
        call EnableDragSelect(true, true)
        call EnablePreSelect(true, true)
    elseif args == "darkness" then
        call ResetTerrainFog()
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Fix takes nothing returns nothing
    call LoP_Command.create("-fix", ACCESS_USER, Condition(function OnCommand ))
endfunction

endscope
