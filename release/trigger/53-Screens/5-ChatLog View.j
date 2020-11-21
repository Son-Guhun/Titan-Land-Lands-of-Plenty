library ChatLogView requires Screen, UILib, OOP

globals
    public Screen mainFrame
endglobals

//! runtextmacro Begin0SecondInitializer("Init")
    local framehandle mainButton
    
    call BlzLoadTOCFile("war3mapimported\\Templates.toc")
    
    set mainFrame = Screen.create()
    call mainFrame.show(false)
    
    set mainButton =  BlzCreateFrame("EscMenuTextAreaTemplate", mainFrame.main,0,0)
    call BlzFrameSetSize(mainButton, 0.2, 0.395)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, UIView.RIGHT_BORDER, FRAMEPOINT_LEFT, 0., .055)
    //call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, UIView.RIGHT_BORDER, FRAMEPOINT_LEFT, 0., View4by3.h/2+.055)
    // call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_RIGHT, View4by3.w, View4by3.h/2+.055)
    set mainFrame["OOC log"] = mainButton
    call BlzFrameSetVisible(mainButton, false)
    
    set mainButton =  BlzCreateFrame("EscMenuTextAreaTemplate", mainFrame.main,0,0)
    call BlzFrameSetAllPoints(mainButton, mainFrame["OOC log"])
    set mainFrame["IC log"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.05, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_BOTTOMRIGHT, mainFrame["OOC log"], FRAMEPOINT_TOPRIGHT, 0, -.0015)
    call BlzFrameSetText(mainButton, "Hide")
    set mainFrame["hideButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.05, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, mainFrame["hideButton"], FRAMEPOINT_LEFT, -0.002, 0)
    call BlzFrameSetText(mainButton, "OOC")
    set mainFrame["switchButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", mainFrame.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.06, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, mainFrame["switchButton"], FRAMEPOINT_LEFT, -0.002, 0)
    call BlzFrameSetText(mainButton, "Close")
    set mainFrame["closeButton"] = mainButton
//! runtextmacro End0SecondInitializer()



endlibrary