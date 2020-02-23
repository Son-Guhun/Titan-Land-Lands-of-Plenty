library DecorationBrowserView

globals
    Screen decorationBrowserScreen
endglobals

//! runtextmacro BeginInitializer("Init")
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
    set decorationBrowserScreen["editBox"] = mainButton
    
    
//! runtextmacro EndInitializer()

endlibrary