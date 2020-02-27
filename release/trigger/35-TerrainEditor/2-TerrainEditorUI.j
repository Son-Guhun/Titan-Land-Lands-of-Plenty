library TerrainEditorUI requires TerrainEditor, TerrainEditorUIController
    
    public function Activate takes player whichPlayer returns nothing
        
        call TerrainEditor_controlState.activateForPlayer(whichPlayer)
        call TerrainEditorUIController_controller.enable(whichPlayer, true)
    endfunction
    
    public function Deactivate takes player whichPlayer returns nothing
        call ControlState.default.activateForPlayer(whichPlayer)
        call TerrainEditorUIController_controller.enable(whichPlayer, false)
    endfunction

endlibrary