library MainMenuView requires Screen, UILib

globals
    public Screen mainFrame
endglobals

//! runtextmacro BeginInitializer("Init")
    local framehandle mainButton
    
    set mainFrame = Screen.create()
    call mainFrame.show(false)
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 7*View4by3.h/8)
    call BlzFrameSetText(mainButton, "Terrain Editor")
    set mainFrame["terrainEditor"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 6*View4by3.h/8)
    call BlzFrameSetText(mainButton, "Free Camera")
    set mainFrame["freeCamera"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 5*View4by3.h/8)
    call BlzFrameSetText(mainButton, "SotDRP Mode")
    set mainFrame["sotdrp"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, View4by3.w/2, 4*View4by3.h/8)
    call BlzFrameSetText(mainButton, "Special Units")
    set mainFrame["specialUnits"] = mainButton
//! runtextmacro EndInitializer()



endlibrary