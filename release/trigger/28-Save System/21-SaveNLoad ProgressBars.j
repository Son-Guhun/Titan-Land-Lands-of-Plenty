library SaveNLoadProgressBars

globals
    framehandle saveUnitBar
    framehandle saveTerrainBar
    framehandle saveUnitBarText
    framehandle saveTerrainBarText
endglobals


//! runtextmacro BeginInitializer("Init")
    call BJDebugMsg("aaaa")
    call BlzLoadTOCFile("war3mapimported\\simplestatusbars.toc")

    set saveUnitBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0)
    set saveTerrainBar = BlzCreateSimpleFrame("MyBarEx", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 1)
    set saveUnitBarText = BlzGetFrameByName("MyBarExText",0)
    set saveTerrainBarText = BlzGetFrameByName("MyBarExText",1)
    
    
    call BlzFrameSetAbsPoint(saveUnitBar, FRAMEPOINT_TOP, 0.4, 0.5725 - 0.012*2) // pos the bar
    call BlzFrameSetPoint(saveTerrainBar, FRAMEPOINT_TOP, saveUnitBar, FRAMEPOINT_BOTTOM, 0.0, 0.0) // pos bar2 below bar
    
    call BlzFrameSetSize(saveUnitBar, BlzFrameGetWidth(saveUnitBar)*3, BlzFrameGetHeight(saveUnitBar)*1.5)
    call BlzFrameSetSize(saveTerrainBar, BlzFrameGetWidth(saveTerrainBar)*3, BlzFrameGetHeight(saveTerrainBar)*1.5)

    call BlzFrameSetTexture(saveUnitBar, "Replaceabletextures\\Teamcolor\\Teamcolor00.blp", 0, true) //change the BarTexture of bar to color red
    call BlzFrameSetTexture(saveTerrainBar, "Replaceabletextures\\Teamcolor\\Teamcolor01.blp", 0, true) //color blue for bar2
    
    call BJDebugMsg("aaaa")

    //call BlzFrameSetVisible(saveUnitBar, false)
    //call BlzFrameSetVisible(saveTerrainBar, false)
//! runtextmacro EndInitializer()

endlibrary