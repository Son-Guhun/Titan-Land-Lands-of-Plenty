scope CommandsEditor

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    
    if args == "none" then
        call TerrainEditorUI_Deactivate(GetTriggerPlayer())
    elseif args == "terrain" then
        call TerrainEditorUI_Activate(GetTriggerPlayer())
    elseif args == "height on" then
        if TerrainEditorUIController_heightEnabled then
            call TerrainEditor_SetHeightTool(GetTriggerPlayer(), 1)
        endif
    elseif args == "height off" then
        call TerrainEditor_SetHeightTool(GetTriggerPlayer(), 0)
    elseif args == "painting on" then
        call TerrainEditor_EnablePainting(GetTriggerPlayer(), true)
    elseif args == "painting off" then
        call TerrainEditor_EnablePainting(GetTriggerPlayer(), false)
    elseif args == "enable height" and GetTriggerPlayer() == udg_GAME_MASTER then
        set TerrainEditorUIController_heightEnabled = true
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Editor takes nothing returns nothing
    call LoP_Command.create("-editor", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
