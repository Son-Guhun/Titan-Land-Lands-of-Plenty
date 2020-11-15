library SaveNLoadProgressBars
/*
    A view-type library that defines the loading bars used when players are saving/loading.

*/

globals
    framehandle saveUnitBar
    framehandle saveTerrainBar
    framehandle saveUnitBarText
    framehandle saveTerrainBarText
    framehandle loadBar
    framehandle loadBarText
endglobals


//! runtextmacro Begin0SecondInitializer("Init")
    call BlzLoadTOCFile("war3mapimported\\simplestatusbars.toc")

    set saveUnitBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    set saveUnitBarText = BlzGetFrameByName("MyBarExText",0)
    set saveTerrainBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    set saveTerrainBarText = BlzGetFrameByName("MyBarExText",0)
    set loadBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    set loadBarText = BlzGetFrameByName("MyBarExText", 0)
    
    
    call BlzFrameSetAbsPoint(saveUnitBar, FRAMEPOINT_TOP, 0.4, 0.5725 - 0.012*2)
    call BlzFrameSetPoint(saveTerrainBar, FRAMEPOINT_TOP, saveUnitBar, FRAMEPOINT_BOTTOM, 0.0, 0.0)
    call BlzFrameSetPoint(loadBar, FRAMEPOINT_TOP, saveTerrainBar, FRAMEPOINT_BOTTOM, 0.0, 0.0)
    
    call BlzFrameSetSize(saveUnitBar, BlzFrameGetWidth(saveUnitBar)*3, BlzFrameGetHeight(saveUnitBar)*1.5)
    call BlzFrameSetSize(saveTerrainBar, BlzFrameGetWidth(saveTerrainBar)*3, BlzFrameGetHeight(saveTerrainBar)*1.5)
    call BlzFrameSetSize(loadBar, BlzFrameGetWidth(loadBar)*3, BlzFrameGetHeight(loadBar)*1.5)

    call BlzFrameSetTexture(saveUnitBar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true)
    call BlzFrameSetTexture(saveTerrainBar, "Replaceabletextures\\Teamcolor\\Teamcolor01.blp", 0, true)
    call BlzFrameSetTexture(loadBar, "Replaceabletextures\\Teamcolor\\Teamcolor05.blp", 0, true)

    call BlzFrameSetVisible(saveUnitBar, false)
    call BlzFrameSetVisible(saveTerrainBar, false)
    call BlzFrameSetVisible(loadBar, false)
//! runtextmacro End0SecondInitializer()

endlibrary