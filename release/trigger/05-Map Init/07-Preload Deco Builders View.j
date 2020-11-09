library PreloadDecoBuildersView requires LoPUI

globals
    public framehandle loadBar
    public framehandle loadBarText
    public framehandle textBox
endglobals


//! runtextmacro Begin0SecondInitializer("Init")
    call BlzLoadTOCFile("war3mapimported\\simplestatusbars.toc")


    set loadBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    set loadBarText = BlzGetFrameByName("MyBarExText", 0)
    
    set textBox = BlzCreateFrame("BoxedText", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)

    call BlzFrameSetAbsPoint(loadBar, FRAMEPOINT_TOP, 0.4, 0.6/2)
    
    call BlzFrameSetSize(loadBar, BlzFrameGetWidth(loadBar)*3, BlzFrameGetHeight(loadBar)*1.5)

    call BlzFrameSetTexture(loadBar, "Replaceabletextures\\Teamcolor\\Teamcolor05.blp", 0, true)
    
    call BlzFrameSetPoint(textBox, FRAMEPOINT_BOTTOM, loadBar, FRAMEPOINT_TOP, 0., 0.)
    call BlzFrameSetSize(textBox, 0.4, 0.075)
    call BlzFrameSetText(BlzGetFrameByName("BoxedTextTitle", 0), "Preloading")
    call BlzFrameSetText(BlzGetFrameByName("BoxedTextValue", 0), "Due to Reforged being launched in an utterly broken state, Deco Builders must now be preloaded. Please wait momentairly.

Hey, at least this loading bar actually works.")

    call BlzFrameSetVisible(loadBar, false)
    call BlzFrameSetVisible(textBox, false)
//! runtextmacro End0SecondInitializer()

endlibrary