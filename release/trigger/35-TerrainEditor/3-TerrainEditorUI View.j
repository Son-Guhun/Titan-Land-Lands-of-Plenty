library TerrainEditorUIView requires Screen, TerrainEditor

globals
    Screen terrainEditorScreen
endglobals

//! runtextmacro BeginInitializer("Init")
    local framehandle mainButton
    
    call BlzLoadTOCFile("war3mapImported\\Templates.toc")
    call BlzLoadTOCFile("war3mapImported\\terraineditor.toc")
    
    set terrainEditorScreen = Screen.createWithSimple()
    call terrainEditorScreen.show(false)
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.06, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_LEFT, 0.0,0.595)
    call BlzFrameSetText(mainButton, "Exit")
    set terrainEditorScreen["exitButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, 0.3,0.595)
    call BlzFrameSetText(mainButton, "Texturing: On")
    set terrainEditorScreen["paintButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.06, 0.05)
    call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, 0.5,0.595)
    call BlzFrameSetText(mainButton, "None")
    set terrainEditorScreen["heightButton"] = mainButton
    call BlzFrameSetEnable(mainButton, false)
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.05, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_LEFT, terrainEditorScreen["heightButton"], FRAMEPOINT_RIGHT, 0., 0.)
    call BlzFrameSetText(mainButton, "Hill")
    set terrainEditorScreen["hillButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.08, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_LEFT, terrainEditorScreen["hillButton"], FRAMEPOINT_RIGHT, 0., 0.)
    call BlzFrameSetText(mainButton, "Plateau")
    set terrainEditorScreen["plateauButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.07, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_LEFT, terrainEditorScreen["plateauButton"], FRAMEPOINT_RIGHT, 0., 0.)
    call BlzFrameSetText(mainButton, "Smooth")
    set terrainEditorScreen["smoothButton"] = mainButton
    
    set mainButton = BlzCreateFrame("EscMenuEditBoxTemplate", terrainEditorScreen.main,0,0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOPLEFT, terrainEditorScreen["plateauButton"], FRAMEPOINT_BOTTOMLEFT, 0., 0.)  
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOPRIGHT, terrainEditorScreen["plateauButton"], FRAMEPOINT_BOTTOMRIGHT, 0., 0.)  
    call BlzFrameSetSize(mainButton, 0.12, 0.03)
    call BlzFrameSetTextSizeLimit(mainButton, 5)
    set terrainEditorScreen["plateauInput"] = mainButton
    call BlzFrameSetText(mainButton, "0")
    call BlzFrameSetVisible(mainButton, false)
    
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen["plateauInput"], "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, terrainEditorScreen["plateauInput"], FRAMEPOINT_LEFT, 0, 0)
    call BlzFrameSetText(mainButton, "Plateau Height:")
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, terrainEditorScreen["heightButton"], FRAMEPOINT_LEFT, 0, 0)
    call BlzFrameSetText(mainButton, "Height Tool:")
    
    set mainButton = BlzCreateFrame("EscMenuSliderTemplate", terrainEditorScreen.main,0,0) // BlzCreateFrameByType( "SLIDER", "Test", terrainEditorScreen.main, "EscMenuSliderTemplate", 0 )
    call BlzFrameClearAllPoints(mainButton)
    // call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, 0.4, 0.3)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, terrainEditorScreen["paintButton"], FRAMEPOINT_BOTTOM, 0., 0.)
    call BlzFrameSetMinMaxValue(mainButton, 1., 5.)
    call BlzFrameSetStepSize(mainButton, 1)
    // call BlzFrameSetSize(mainButton, 0.5, 0.012)
    set terrainEditorScreen["brushSizeSlider"] = mainButton
    
    set terrainEditorScreen["brushSizeSliderButton"] = BlzGetFrameByName("EscMenuThumbButtonTemplate",0)
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, terrainEditorScreen["brushSizeSlider"], FRAMEPOINT_BOTTOMLEFT, 0.0031 + 0.1*BlzFrameGetWidth(terrainEditorScreen["brushSizeSlider"])/4, 0)
    call BlzFrameSetText(mainButton, "1")
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, terrainEditorScreen["brushSizeSlider"], FRAMEPOINT_BOTTOMRIGHT, -0.0031 - 0.1*BlzFrameGetWidth(terrainEditorScreen["brushSizeSlider"])/4, 0)
    call BlzFrameSetText(mainButton, "5")
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, terrainEditorScreen["brushSizeSlider"], FRAMEPOINT_BOTTOMLEFT, 0.0031+BlzFrameGetWidth(terrainEditorScreen["brushSizeSlider"])/4, 0)
    call BlzFrameSetText(mainButton, "2")
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, terrainEditorScreen["brushSizeSlider"], FRAMEPOINT_BOTTOMLEFT, 2*BlzFrameGetWidth(terrainEditorScreen["brushSizeSlider"])/4, 0)
    call BlzFrameSetText(mainButton, "3")
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, terrainEditorScreen["brushSizeSlider"], FRAMEPOINT_BOTTOMLEFT, -0.0031+3*BlzFrameGetWidth(terrainEditorScreen["brushSizeSlider"])/4, 0)
    call BlzFrameSetText(mainButton, "4")
    
//! runtextmacro EndInitializer()



struct TerrainEditorButton extends array

    static trigger mouseClickHandler = CreateTrigger()
    static trigger mouseEnterHandler = CreateTrigger()
    static trigger mouseLeaveHandler = CreateTrigger()
    static key tabb

    framehandle button
    framehandle background
    framehandle eighthTexture
    framehandle quarterTexture
    framehandle halfTexture
    
    static method fromHandle takes framehandle buttonframe returns thistype
        return Table(tabb)[GetHandleId(buttonframe)]
    endmethod
    
    private static method create takes integer this returns thistype
        set .button = BlzCreateFrame("TerrainEditorButton", terrainEditorScreen.main, 0, this)
        set .background =  BlzCreateSimpleFrame("TerrainEditorSimpleBackground", terrainEditorScreen.simpleContainer, this)
        set .eighthTexture = BlzGetFrameByName("TerrainEditorEighthBackground", this)
        set .quarterTexture = BlzGetFrameByName("TerrainEditorEighthBackground", this)
        set .halfTexture = BlzGetFrameByName("TerrainEditorEighthBackground", this)
        
        call BlzFrameSetSize(.button, 0.05, 0.05)
        call BlzFrameSetAllPoints(.background, .button)
        call BlzTriggerRegisterFrameEvent(mouseClickHandler, .button, FRAMEEVENT_CONTROL_CLICK)
        call BlzTriggerRegisterFrameEvent(mouseEnterHandler, .button, FRAMEEVENT_MOUSE_ENTER)
        call BlzTriggerRegisterFrameEvent(mouseLeaveHandler, .button, FRAMEEVENT_MOUSE_LEAVE)
        
        call BlzFrameSetTexture(.eighthTexture, Tile(TerrainTools_GetTexture(this)).file, 0, false)
        set Table(tabb)[GetHandleId(.button)] = this
        return this
    endmethod
    
    private static method onInit takes nothing returns nothing
        local framehandle text
        local integer i = 1
        
        call BlzLoadTOCFile("war3mapImported\\test.toc")
        
        set thistype(0).button = TerrainEditorButton.create(0).button
        call BlzFrameSetAbsPoint(thistype(0).button, FRAMEPOINT_LEFT, 0.2, 0.075)
        
        loop
            set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
            call BlzFrameSetPoint(text, FRAMEPOINT_BOTTOM, thistype(i-1).button, FRAMEPOINT_TOP, 0, 0)
            call BlzFrameSetText(text, I2S(i))
        
            exitwhen i == 8
            set thistype(i).button = TerrainEditorButton.create(i).button
            call BlzFrameSetPoint(thistype(i).button, FRAMEPOINT_LEFT, thistype(i-1).button, FRAMEPOINT_RIGHT, 0, 0)
            set i = i + 1
        endloop
        
        set thistype(8).button = TerrainEditorButton.create(i).button
        call BlzFrameSetPoint(thistype(8).button, FRAMEPOINT_TOP, thistype(0).button, FRAMEPOINT_BOTTOM, 0, 0)
        
        set i = 9
        loop
        exitwhen i == 16
            set thistype(i).button = TerrainEditorButton.create(i).button
            
            call BlzFrameSetPoint(thistype(i).button, FRAMEPOINT_LEFT, thistype(i-1).button, FRAMEPOINT_RIGHT, 0, 0)
            set i = i + 1
        endloop
        
        set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
        call BlzFrameSetPoint(text, FRAMEPOINT_RIGHT, thistype(0).button, FRAMEPOINT_LEFT, 0, 0)
        call BlzFrameSetText(text, "Shift+")
           
        set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
        call BlzFrameSetPoint(text, FRAMEPOINT_RIGHT, thistype(8).button, FRAMEPOINT_LEFT, 0, 0)
        call BlzFrameSetText(text, "Alt+")
    
    endmethod


endstruct

endlibrary