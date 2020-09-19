library TerrainEditorUIView requires Screen, TerrainEditor, IsMouseOnButton

globals
    Screen terrainEditorScreen
endglobals

//! runtextmacro Begin0SecondInitializer("Init")
    local framehandle mainButton
    
    call BlzLoadTOCFile("war3mapImported\\Templates.toc")
    call BlzLoadTOCFile("war3mapImported\\terraineditor.toc")
    
    set terrainEditorScreen = Screen.createWithSimpleAndTop()
    call terrainEditorScreen.show(false)
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.06, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOPLEFT, UIView.LEFT_BORDER, FRAMEPOINT_TOPLEFT, -0., 0.)
    // call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_TOPLEFT, 0.0,0.6)
    call BlzFrameSetText(mainButton, "Exit")
    set terrainEditorScreen["exitButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.12, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, UIView.LEFT_BORDER, FRAMEPOINT_TOPLEFT, 0.2, 0.)
    // call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_TOP, 0.3,0.6)
    call BlzFrameSetText(mainButton, "Texturing: On")
    set terrainEditorScreen["paintButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.07, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOPRIGHT, UIView.RIGHT_BORDER, FRAMEPOINT_TOPLEFT, 0., 0.)
    call BlzFrameSetText(mainButton, "Smooth")
    set terrainEditorScreen["smoothButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.08, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, terrainEditorScreen["smoothButton"], FRAMEPOINT_LEFT, 0., 0.)
    call BlzFrameSetText(mainButton, "Plateau")
    set terrainEditorScreen["plateauButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.05, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, terrainEditorScreen["plateauButton"], FRAMEPOINT_LEFT, 0., 0.)
    call BlzFrameSetText(mainButton, "Hill")
    set terrainEditorScreen["hillButton"] = mainButton
    
    set mainButton = BlzCreateFrame("ScriptDialogButton", terrainEditorScreen.main, 0,0)
    call BlzFrameSetSize(mainButton, 0.06, 0.03)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_RIGHT, terrainEditorScreen["hillButton"], FRAMEPOINT_LEFT, 0., 0.)
    // call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_TOP, 0.5,0.6)
    call BlzFrameSetText(mainButton, "None")
    set terrainEditorScreen["heightButton"] = mainButton
    call BlzFrameSetEnable(mainButton, false)
    

    

    

    
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
    
    set mainButton = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen.main, "StandardExtraSmallTextTemplate", 0)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_LEFT, terrainEditorScreen["paintButton"], FRAMEPOINT_RIGHT, 0.03, 0)
    call BlzFrameSetText(mainButton, "Brush Size:")
    set terrainEditorScreen["brushSizeText"] = mainButton
    
    set mainButton = BlzCreateFrame("EscMenuSliderTemplate", terrainEditorScreen.main,0,0) // BlzCreateFrameByType( "SLIDER", "Test", terrainEditorScreen.main, "EscMenuSliderTemplate", 0 )
    call BlzFrameClearAllPoints(mainButton)
    // call BlzFrameSetAbsPoint(mainButton, FRAMEPOINT_CENTER, 0.4, 0.3)
    // call BlzFrameSetPoint(mainButton, FRAMEPOINT_TOP, terrainEditorScreen["paintButton"], FRAMEPOINT_BOTTOM, 0., 0.)
    call BlzFrameSetPoint(mainButton, FRAMEPOINT_LEFT, terrainEditorScreen["brushSizeText"], FRAMEPOINT_RIGHT, 0., 0.)
    call BlzFrameSetMinMaxValue(mainButton, 1., 5.)
    call BlzFrameSetStepSize(mainButton, 1)
    // call BlzFrameSetSize(mainButton, 0.5, 0.012)
    set terrainEditorScreen["brushSizeSlider"] = mainButton
    
    set terrainEditorScreen["brushSizeSliderButton"] = BlzGetFrameByName("EscMenuThumbButtonTemplate",0)
    
    set mainButton = BlzCreateFrameByType("FRAME", "TerrainEditorButtonContainer", terrainEditorScreen.topContainer, "", 0)
    set terrainEditorScreen["textureButtonsContainer"] = mainButton
    
    set mainButton = BlzCreateFrameByType("SIMPLEFRAME", "TerrainEditorButtonSimpleContainer", terrainEditorScreen.simpleContainer, "", 0)
    set terrainEditorScreen["textureButtonsSimpleContainer"] = mainButton
    
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
//! runtextmacro End0SecondInitializer()



struct TerrainEditorButton extends array

    static trigger mouseClickHandler
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
        local integer size = TerrainTools_GetTextureSize(this)
    
        set .button = BlzCreateFrame("TerrainEditorButton", terrainEditorScreen["textureButtonsContainer"], 0, this)
        set .background =  BlzCreateSimpleFrame("TerrainEditorSimpleBackground", terrainEditorScreen["textureButtonsSimpleContainer"], this)
        set .eighthTexture = BlzGetFrameByName("TerrainEditorEighthBackground", this)
        set .quarterTexture = BlzGetFrameByName("TerrainEditorQuarterBackground", this)
        set .halfTexture = BlzGetFrameByName("TerrainEditorHalfBackground", this)
        
        call BlzFrameSetSize(.button, 0.035, 0.035)
        call BlzFrameSetAllPoints(.background, .button)
        call IsMouseOnButton_Register(.button)
        call BlzTriggerRegisterFrameEvent(mouseClickHandler, .button, FRAMEEVENT_CONTROL_CLICK)
        
        if size == 1 then
            call BlzFrameSetTexture(.quarterTexture, Tile(TerrainTools_GetTexture(this)).file, 0, false)
        elseif size == 2 then
            call BlzFrameSetTexture(.eighthTexture, Tile(TerrainTools_GetTexture(this)).file, 0, false)
        elseif size == 3 then
            call BlzFrameSetTexture(.halfTexture, Tile(TerrainTools_GetTexture(this)).file, 0, false)
        endif
        set Table(tabb)[GetHandleId(.button)] = this
        return this
    endmethod
    
    private static method onStart takes nothing returns nothing
        local framehandle text
        // local framehandle box = BlzCreateFrame("BoxedText", terrainEditorScreen["textureButtonsContainer"], 0, 0)
        local integer i = 1
        
        set thistype(0).button = TerrainEditorButton.create(0).button
        call BlzFrameSetAbsPoint(thistype(0).button, FRAMEPOINT_TOPLEFT, 0.26, 0.035*2 + .007)
        
        loop
            set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen["textureButtonsContainer"], "StandardExtraSmallTextTemplate", 0)
            call BlzFrameSetPoint(text, FRAMEPOINT_BOTTOM, thistype(i-1).button, FRAMEPOINT_TOP, 0, 0)
            call BlzFrameSetText(text, I2S(i))
        
            exitwhen i == 8
            set thistype(i).button = TerrainEditorButton.create(i).button
            call BlzFrameSetPoint(thistype(i).button, FRAMEPOINT_LEFT, thistype(i-1).button, FRAMEPOINT_RIGHT, 0, 0)
            set i = i + 1
        endloop
        // call BlzFrameSetPoint(box, FRAMEPOINT_TOPRIGHT, text, FRAMEPOINT_TOPRIGHT, 0.05, 0.02)
        
        set thistype(8).button = TerrainEditorButton.create(i).button
        call BlzFrameSetPoint(thistype(8).button, FRAMEPOINT_TOP, thistype(0).button, FRAMEPOINT_BOTTOM, 0, 0)
        
        set i = 9
        loop
        exitwhen i == 16
            set thistype(i).button = TerrainEditorButton.create(i).button
            
            call BlzFrameSetPoint(thistype(i).button, FRAMEPOINT_LEFT, thistype(i-1).button, FRAMEPOINT_RIGHT, 0, 0)
            set i = i + 1
        endloop
        
        set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen["textureButtonsContainer"], "StandardExtraSmallTextTemplate", 0)
        call BlzFrameSetPoint(text, FRAMEPOINT_RIGHT, thistype(0).button, FRAMEPOINT_LEFT, 0, 0)
        call BlzFrameSetText(text, "Shift+")
           
        set text = BlzCreateFrameByType("TEXT", "HotkeyIndicator", terrainEditorScreen["textureButtonsContainer"], "StandardExtraSmallTextTemplate", 0)
        call BlzFrameSetPoint(text, FRAMEPOINT_RIGHT, thistype(8).button, FRAMEPOINT_LEFT, 0, 0)
        call BlzFrameSetText(text, "Alt+")
        // call BlzFrameSetPoint(box, FRAMEPOINT_BOTTOMLEFT, text, FRAMEPOINT_BOTTOMLEFT, -0.03, -0.05)
        
        call DestroyTimer(GetExpiredTimer())
    endmethod
    
    private static method onInit takes nothing returns nothing
        set mouseClickHandler = CreateTrigger()
        call TimerStart(CreateTimer(), 0., false, function thistype.onStart)
    endmethod


endstruct

endlibrary