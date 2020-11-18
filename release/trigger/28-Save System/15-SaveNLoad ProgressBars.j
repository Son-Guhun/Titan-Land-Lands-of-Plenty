library SaveNLoadProgressBars
/*
    A view-type library that defines the loading bars used when players are saving/loading.

*/

globals
    framehandle saveProgressBar
    framehandle saveProgressBarText
    framehandle loadBar
    framehandle loadBarText
endglobals

/* Possible future implementation:
struct ProgressBarController extends array
    
    framehandle progressBar
    framehandle textFrame
    framehandle cancelButton
    
    method setProgress takes integer current, integer total returns nothing
        call BlzFrameSetValue(.progressBar, I2R(current)/total)
        call BlzFrameSetText(.textFrame, I2S(current) + " / " + I2S(total))
    endmethod
    
    method setMessage takes string msg returns nothing
        call BlzFrameSetText(.textFrame, msg)
    endmethod
    
    method operator onCancel= takes boolexpr callback returns nothing
        // attach callback to cancelButton
    endmethod
    
endstruct
*/

//! runtextmacro Begin0SecondInitializer("Init")
    call BlzLoadTOCFile("war3mapimported\\simplestatusbars.toc")

    set saveProgressBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    set saveProgressBarText = BlzGetFrameByName("MyBarExText",0)
    set loadBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    set loadBarText = BlzGetFrameByName("MyBarExText", 0)
    
    
    call BlzFrameSetAbsPoint(saveProgressBar, FRAMEPOINT_TOP, 0.4, 0.5725 - 0.012*2)
    call BlzFrameSetPoint(loadBar, FRAMEPOINT_TOP, saveProgressBar, FRAMEPOINT_BOTTOM, 0.0, 0.0)
    
    call BlzFrameSetSize(saveProgressBar, BlzFrameGetWidth(saveProgressBar)*3, BlzFrameGetHeight(saveProgressBar)*1.5)
    call BlzFrameSetSize(loadBar, BlzFrameGetWidth(loadBar)*3, BlzFrameGetHeight(loadBar)*1.5)

    call BlzFrameSetTexture(saveProgressBar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true)
    call BlzFrameSetTexture(loadBar, "Replaceabletextures\\Teamcolor\\Teamcolor05.blp", 0, true)

    call BlzFrameSetVisible(saveProgressBar, false)
    call BlzFrameSetVisible(loadBar, false)
//! runtextmacro End0SecondInitializer()

endlibrary