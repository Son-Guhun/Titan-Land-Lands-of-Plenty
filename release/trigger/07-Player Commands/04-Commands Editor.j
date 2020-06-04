scope CommandsEditor

private function onCommand takes nothing returns boolean
    local string args = LoP_Command.getArguments()
    
    if args == "none" then
        call TerrainEditorUI_Deactivate(GetTriggerPlayer())
        if User.Local == GetTriggerPlayer() then
            set LoPUI_altZEnabled = true
            call FullScreen(false, 255)
        endif
    elseif args == "terrain" then
        call TerrainEditorUI_Activate(GetTriggerPlayer())
        if User.Local == GetTriggerPlayer() then
            set LoPUI_altZEnabled = false
            call FullScreen(true, 255)
        endif
    elseif args == "enable height" and GetTriggerPlayer() == udg_GAME_MASTER then
        set TerrainEditorUIController_heightEnabled = true
    elseif args == "disable height" and GetTriggerPlayer() == udg_GAME_MASTER then
        set TerrainEditorUIController_heightEnabled = false
    endif
    
    return false
endfunction

//===========================================================================
function InitTrig_Commands_Editor takes nothing returns nothing
    call LoP_Command.create("-editor", ACCESS_USER, Condition(function onCommand ))
endfunction

endscope
