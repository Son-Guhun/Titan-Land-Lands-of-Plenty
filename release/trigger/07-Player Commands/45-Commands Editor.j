scope CommandsEditor

function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    
    if args == "none" then
        call TerrainEditorUI_Deactivate(GetTriggerPlayer())
    elseif args == "terrain" then
        call TerrainEditorUI_Activate(GetTriggerPlayer())
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Editor takes nothing returns nothing
    call LoP_Command.create("-editor", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
