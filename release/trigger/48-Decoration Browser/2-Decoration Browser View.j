library DecorationBrowserView requires Screen

globals
    Screen decorationBrowserScreen
endglobals

//! runtextmacro Begin0SecondInitializer("Init")
    local framehandle mainButton
    
    set decorationBrowserScreen = Screen.create()
    call decorationBrowserScreen.show(false)
    
    call BlzLoadTOCFile("war3mapImported\\Templates.toc")
    call BlzLoadTOCFile("war3mapImported\\boxedtext.toc")
    
    set mainButton = BlzCreateFrame("QuestButtonBaseTemplate", decorationBrowserScreen.main,0,0)
    set decorationBrowserScreen["backdrop"] = mainButton

    set mainButton = BlzCreateFrame("EscMenuEditBoxTemplate", decorationBrowserScreen["backdrop"],0,0)
    // call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, 0.4, 0.18)    
    call BlzFrameSetSize(mainButton, 0.6, 0.028)
    call BlzFrameSetTextSizeLimit(mainButton, 25)
    set decorationBrowserScreen["editBox"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", decorationBrowserScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.06, 0.028)
    call BlzFrameSetText(mainButton, "Swap")
    set decorationBrowserScreen["switchButton"] = mainButton
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", decorationBrowserScreen.main, "StandardTitleTextTemplate", 0)
    //call BlzFrameSetPoint(mainButton, FRAMEPOINT_BOTTOM, decorationBrowserScreen["backdrop"], FRAMEPOINT_TOP, 0, 0)
    call BlzFrameSetText(mainButton, "Classic Decorations")
    call BlzFrameSetTextAlignment(mainButton, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
    set decorationBrowserScreen["titleText"] = mainButton
//! runtextmacro End0SecondInitializer()

endlibrary