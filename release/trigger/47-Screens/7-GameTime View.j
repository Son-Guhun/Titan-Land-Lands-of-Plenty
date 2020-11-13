library GameTimeView requires TableStruct

public struct frames extends array
    private static key static_members_key
    
    //! runtextmacro TableStruct_NewStaticHandleField("hours", "framehandle")
    //! runtextmacro TableStruct_NewStaticHandleField("minutes", "framehandle")
    //! runtextmacro TableStruct_NewStaticHandleField("seconds", "framehandle")
endstruct

//! runtextmacro Begin0SecondInitializer("Init")
    local framehandle mainButton
    local framehandle text
    local framehandle prev
    
    // set mainButton = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0,0)
    set mainButton = BlzCreateFrameByType("TEXT", "GameTimeDummyFrame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_TOP, 0.4, 0.6)
    call BlzFrameSetSize(mainButton, 0.08, 0.05)
    set prev = mainButton
    
    // set mainButton = BlzCreateFrame("ScriptDialogButton", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0,0)
    set mainButton = BlzCreateFrameByType("TEXT", "GameTimeDummyFrame", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
    call BlzFrameSetTooltip(prev, mainButton)
    
    set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", mainButton, "StandardExtraSmallTextTemplate", 0)
    // call BlzFrameSetAbsPoint(text, FRAMEPOINT_RIGHT, 0.4, 0.3)
    call BlzFrameSetAbsPoint(text, FRAMEPOINT_TOP, 0.4, 0.55)
    // call BlzFrameSetPoint(text, FRAMEPOINT_TOP, mainButton, FRAMEPOINT_BOTTOM, -0.04, 0.)
    call BlzFrameSetText(text, "00")
    set prev = text
    set frames.hours = text
    
    set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", mainButton, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(text, FRAMEPOINT_LEFT, prev, FRAMEPOINT_RIGHT, 0, 0)
    call BlzFrameSetText(text, ":")
    set prev = text
    
    set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", mainButton, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(text, FRAMEPOINT_LEFT, prev, FRAMEPOINT_RIGHT, 0, 0)
    call BlzFrameSetText(text, "00")
    set prev = text
    set frames.minutes = text
    
    set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", mainButton, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(text, FRAMEPOINT_LEFT, prev, FRAMEPOINT_RIGHT, 0, 0)
    call BlzFrameSetText(text, ":")
    set prev = text
    
    set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", mainButton, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(text, FRAMEPOINT_LEFT, prev, FRAMEPOINT_RIGHT, 0, 0)
    call BlzFrameSetText(text, "00")
    set prev = text
    set frames.seconds = text
    
    
//! runtextmacro End0SecondInitializer()

endlibrary

    
    