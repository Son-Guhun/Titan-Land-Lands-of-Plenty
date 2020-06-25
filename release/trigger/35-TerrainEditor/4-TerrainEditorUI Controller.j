library TerrainEditorUIController requires UILib, PlayerUtils, BitFlags, TerrainEditorUIView, TerrainEditor, IsMouseOnButton, EditBoxFix

globals
    public boolean heightEnabled = false
    public ScreenController controller
    private framehandle lastButton = null
endglobals



function ButtonCallback takes player trigP, framehandle trigButton returns nothing
    local User pId = User[trigP]
    
    if trigButton == terrainEditorScreen["heightButton"] then
        call TerrainEditor_SetHeightTool(trigP, 0)
        //! textmacro TerrainEditor_ButtonCallback_onPress takes condition, tool
            if $condition$ then
                call TerrainEditor_SetHeightTool(trigP, $tool$)
        
                if User.Local == trigP then
                    call BlzFrameSetEnable(terrainEditorScreen["heightButton"], trigButton != terrainEditorScreen["heightButton"])
                    call BlzFrameSetEnable(terrainEditorScreen["hillButton"], trigButton != terrainEditorScreen["hillButton"])
                    call BlzFrameSetEnable(terrainEditorScreen["plateauButton"], trigButton != terrainEditorScreen["plateauButton"])
                    call BlzFrameSetEnable(terrainEditorScreen["smoothButton"], trigButton != terrainEditorScreen["smoothButton"])
                    call BlzFrameSetVisible(terrainEditorScreen["plateauInput"], trigButton == terrainEditorScreen["plateauButton"])
                endif
            else
                call DisplayTextToPlayer(trigP, 0., 0., "The Titan must enable height with |cffffff00-editor enable height|r. Not recommended for multiplayer.")
            endif
        //! endtextmacro
        //! runtextmacro TerrainEditor_ButtonCallback_onPress("true", "0")
    elseif trigButton == terrainEditorScreen["plateauButton"] then
        //! runtextmacro TerrainEditor_ButtonCallback_onPress("heightEnabled", "TerrainEditor_HEIGHT_TOOL_PLATEAU")
    elseif trigButton == terrainEditorScreen["hillButton"] then
        //! runtextmacro TerrainEditor_ButtonCallback_onPress("heightEnabled", "TerrainEditor_HEIGHT_TOOL_HILL")
    elseif trigButton == terrainEditorScreen["smoothButton"] then
        //! runtextmacro TerrainEditor_ButtonCallback_onPress("heightEnabled", "TerrainEditor_HEIGHT_TOOL_SMOOTH")
    elseif trigButton == terrainEditorScreen["paintButton"] then
        if TerrainEditor_IsPainting(trigP) then
            call LocalFrameSetText(trigP, trigButton, "Texturing: Off")
            call TerrainEditor_EnablePainting(trigP, false)
        else
            call LocalFrameSetText(trigP, trigButton, "Texturing: On")
            call TerrainEditor_EnablePainting(trigP, true)
        endif
    else
        set TerrainEditor_currentTexture[pId] = TerrainTools_GetTexture(TerrainEditorButton.fromHandle(trigButton))
    
        if User.fromLocal() == pId then
            call BlzFrameSetEnable(trigButton, false)
            call BlzFrameSetEnable(lastButton, true)
            set lastButton = trigButton
        endif
    endif
    
    if trigP == User.Local and BlzFrameGetEnable(trigButton) then
        call BlzFrameSetEnable(trigButton, false) //disable the clicked button
        call BlzFrameSetEnable(trigButton, true) //enable it again.
    endif
endfunction

private function onClick takes nothing returns nothing
    call ButtonCallback(GetTriggerPlayer(), BlzGetTriggerFrame())
endfunction

private function onPress takes nothing returns boolean
    local integer number = GetHandleId(BlzGetTriggerPlayerKey()) - $30
    local player trigP = GetTriggerPlayer()
    
    if controller.isEnabled(trigP) then
        if BlzGetTriggerPlayerIsKeyDown() then
            if BlzGetTriggerPlayerMetaKey() == 0 then
                if number > 0 and number < 6 then
                    call TerrainEditor_SetBrushSize(trigP, number*2-1)
                    if User.Local == trigP then
                        call BlzFrameSetValue(terrainEditorScreen["brushSizeSlider"], number)
                    endif
                elseif BlzGetTriggerPlayerKey() == OSKEY_H then
                    call ButtonCallback(trigP, terrainEditorScreen["heightButton"])
                elseif BlzGetTriggerPlayerKey() == OSKEY_P then
                    call ButtonCallback(trigP, terrainEditorScreen["paintButton"])
                endif
            else
                if number > 0 and number < 9 then
                    if BlzGetTriggerPlayerMetaKey() == MetaKeys.ALT then
                        set number = number + 7
                    else
                        set number = number - 1
                    endif
                    if TerrainEditor_currentTexture[User[trigP]] != TerrainTools_GetTexture(number) then
                        call ButtonCallback(trigP, TerrainEditorButton(number).button)
                    endif
                endif
            endif
        endif
    endif
    return true
endfunction

function onChangeValue takes nothing returns nothing
    call TerrainEditor_SetBrushSize(GetTriggerPlayer(), R2I(BlzGetTriggerFrameValue())*2-1)
endfunction

function onEditText takes nothing returns nothing
    local framehandle frame = BlzGetTriggerFrame()
    local player trigP = GetTriggerPlayer()
    local real value = -S2R(BlzGetTriggerFrameText())
    
    if value > Deformations_MAX_HEIGHT then
        set value = Deformations_MAX_HEIGHT
        call LocalFrameSetText(trigP, frame, I2S(R2I(-value)))
    elseif value < Deformations_MIN_HEIGHT then
        set value = Deformations_MIN_HEIGHT
        call LocalFrameSetText(trigP, frame, I2S(R2I(-value)))
    endif
    
    
    set TerrainEditor_plateauLevel[User[trigP]] = value
endfunction
//===========================================================================
//! runtextmacro Begin0SecondInitializer("Init")
    local trigger trig = CreateTrigger()
    
    call BlzTriggerRegisterFrameEvent(TerrainEditorButton.mouseClickHandler, terrainEditorScreen["paintButton"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(TerrainEditorButton.mouseClickHandler, terrainEditorScreen["heightButton"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(TerrainEditorButton.mouseClickHandler, terrainEditorScreen["hillButton"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(TerrainEditorButton.mouseClickHandler, terrainEditorScreen["plateauButton"], FRAMEEVENT_CONTROL_CLICK)
    call BlzTriggerRegisterFrameEvent(TerrainEditorButton.mouseClickHandler, terrainEditorScreen["smoothButton"], FRAMEEVENT_CONTROL_CLICK)
    
    call TriggerAddAction(TerrainEditorButton.mouseClickHandler, function onClick)
    
    call IsMouseOnButton_Register(terrainEditorScreen["paintButton"])
    call IsMouseOnButton_Register(terrainEditorScreen["heightButton"])
    call IsMouseOnButton_Register(terrainEditorScreen["hillButton"])
    call IsMouseOnButton_Register(terrainEditorScreen["plateauButton"])
    call IsMouseOnButton_Register(terrainEditorScreen["plateauInput"])
    call IsMouseOnButton_Register(terrainEditorScreen["smoothButton"])
    call IsMouseOnButton_Register(terrainEditorScreen["exitButton"])
        
    call BlzTriggerRegisterFrameEvent(trig, terrainEditorScreen["plateauInput"], FRAMEEVENT_EDITBOX_TEXT_CHANGED)
    call TriggerAddAction(trig, function onEditText)
    
    set trig = CreateTrigger()
    call BlzFrameSetValue(terrainEditorScreen["brushSizeSlider"], 3.)
    call TriggerAddAction(trig, function onChangeValue)
    call BlzTriggerRegisterFrameEvent(trig, terrainEditorScreen["brushSizeSlider"], FRAMEEVENT_SLIDER_VALUE_CHANGED)
    call IsMouseOnButton_Register(terrainEditorScreen["brushSizeSlider"])
    call IsMouseOnButton_Register(terrainEditorScreen["brushSizeSliderButton"])
    
    call EditBoxFix_Register(terrainEditorScreen["plateauInput"])
    
    
    call OSKeys.KEY1.register()
    call OSKeys.KEY2.register()
    call OSKeys.KEY3.register()
    call OSKeys.KEY4.register()
    call OSKeys.KEY5.register()
    call OSKeys.KEY6.register()
    call OSKeys.KEY7.register()
    call OSKeys.KEY8.register()
    call OSKeys.KEY9.register()
    call OSKeys.H.register()
    call OSKeys.P.register()
    set controller = ScreenController.create(terrainEditorScreen, Condition(function onPress))
//! runtextmacro End0SecondInitializer()

endlibrary