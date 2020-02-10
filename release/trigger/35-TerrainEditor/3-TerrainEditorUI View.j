library TerrainEditorUIView requires Screen, TerrainEditor

globals
    public Screen mainFrame
endglobals


//! runtextmacro BeginInitializer("Init")
    local framehandle mainButton
    
    set mainFrame = Screen.create()
    call mainFrame.show(false)
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, 0.3,0.595)
    call BlzFrameSetText(mainButton, "Texturing: On")
    set mainFrame["paintButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, 0.5,0.595)
    call BlzFrameSetText(mainButton, "Heighting: Hill")
    set mainFrame["heightButton"] = mainButton
    
    call BlzFrameSetVisible(BlzGetFrameByName("ResourceBarFrame", 0), false)
//! runtextmacro EndInitializer()


endlibrary