library TerrainEditorUI requires TerrainEditor, PlayerUtils, TerrainEditorUIController
    
    public function Activate takes player whichPlayer returns nothing
        if User.Local == whichPlayer then
            call VolumeGroupSetVolume(SOUND_VOLUMEGROUP_UI, 0.)
        endif
        call TerrainEditor_controlState.activateForPlayer(whichPlayer)
        call TerrainEditorUIController_controller.enable(whichPlayer, true)
    endfunction
    
    public function Deactivate takes player whichPlayer returns nothing
        if User.Local == whichPlayer then
            call VolumeGroupReset()
        endif
        call ControlState.default.activateForPlayer(whichPlayer)
        call TerrainEditorUIController_controller.enable(whichPlayer, false)
    endfunction

endlibrary