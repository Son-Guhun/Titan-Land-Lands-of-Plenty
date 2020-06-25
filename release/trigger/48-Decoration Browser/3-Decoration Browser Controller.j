library DecorationBrowserController requires DecorationBrowserView, ListBox, RegisterClassicDecorations, SpecialEffect, ControlState, IsMouseOnButton, EditBoxFix, optional LoPUnitCompatibility

//! runtextmacro optional LoPUnitCompatibility()

globals
    private DecorationList array playerLists
    private boolean array isReforged
    private key searchStrings  // table of search strings for each player. Used so RefreshList can be used when a player swaps lists, instead of having to fire an editbox event.
endglobals


private function onPacket takes nothing returns boolean
    local RealPacket packet = RealPacket.eventPacket

    call CreateUnit(GetTriggerPlayer(), packet.metaData[0], packet[0], packet[1], 270.)

    call packet.destroy()
    return false
endfunction

globals
    public ScreenController controller
    public ControlState controlState
    private SpecialEffect array effects
endglobals

struct DecorationsListbox extends array
    static constant framepointtype startFramepoint = FRAMEPOINT_RIGHT
    static constant real startPointX = 0.78
    static constant real startPointY = 0.510
    static constant integer numberOfEntries = 13
    static constant string frameName = "ScriptDialogButton"
    static constant real sizeX = 0.250
    static constant real sizeY = 0.028*13
    static constant boolean LISTBOX_SKIP_INIT = true
    
    
    static method operator parentFrame takes nothing returns framehandle
        return decorationBrowserScreen.main
    endmethod
    
    static method operator initialSize takes nothing returns integer
        return DecorationList.get("").size - 1
    endmethod

    static method updateFrame takes integer frameIndex, integer listIndex returns nothing
        local integer typeId
        
        if isReforged[User.fromLocal()] then
            set typeId = ReforgedDecorationList(playerLists[User.fromLocal()])[listIndex]
        else
            set typeId = playerLists[User.fromLocal()][listIndex]
        endif
        
        if typeId != 0 then
            call BlzFrameSetText(buttons[frameIndex], GetObjectName(typeId))
        else
            call BlzFrameSetText(buttons[frameIndex], "")
        endif
    endmethod
    
    static method onCreateFrame takes integer frameIndex returns nothing
        call BlzFrameSetText(buttons[frameIndex], GetObjectName(DecorationList.get("")[frameIndex]))
        call IsMouseOnButton_Register(buttons[frameIndex])
    endmethod
    
    static method onClickHandler takes player trigP, integer frameIndex, integer listIndex returns nothing
        local User pId = User[trigP]
        
        if effects[pId] != 0 then
            call effects[pId].destroy()
        endif
    
        if isReforged[pId] then
            set effects[pId] = SpecialEffect.create(ReforgedDecorationList(playerLists[User[trigP]])[listIndex], GetPlayerLastMouseX(trigP), GetPlayerLastMouseY(trigP))
        else
            set effects[pId] = SpecialEffect.create(playerLists[User[trigP]][listIndex], GetPlayerLastMouseX(trigP), GetPlayerLastMouseY(trigP))
        endif
        
        set effects[pId].alpha = 128
    endmethod

    implement ListBoxTemplate
endstruct

private function RefreshList takes User pId, string searchStr returns nothing
    local DecorationList list
    
    if isReforged[pId] then
        set list = ReforgedDecorationList.get(searchStr)
        set playerLists[pId] = list
        call DecorationsListbox.changeSize(pId.handle, ReforgedDecorationList(list).size - 1)
    else
        set list = DecorationList.get(searchStr)
        set playerLists[pId] = list
        call DecorationsListbox.changeSize(pId.handle, list.size - 1)
    endif
endfunction

private function onEditText takes nothing returns boolean
    local string text = BlzGetTriggerFrameText()
    local User pId = User[GetTriggerPlayer()]

    call RefreshList(pId, text)
    set Table(searchStrings).string[pId] = text
    
    return true
endfunction

private function onClick takes nothing returns nothing
    local User pId = User[GetTriggerPlayer()]
    local framehandle trigButton = BlzGetTriggerFrame()
    
    // Swap button
        set isReforged[pId] = not isReforged[pId]
        if User.fromLocal() == pId then
            if isReforged[pId] then
                call BlzFrameSetText(decorationBrowserScreen["titleText"], "Reforged Decorations")
            else
                call BlzFrameSetText(decorationBrowserScreen["titleText"], "Classic Decorations")
            endif
        endif
        if not Table(searchStrings).string.has(pId) then
            set Table(searchStrings).string[pId] = ""
        endif
        call RefreshList(pId, Table(searchStrings).string[pId])
    // end swap button
    
    if User.fromLocal() == pId then
        call BlzFrameSetEnable(trigButton, false) //disable the clicked button
        call BlzFrameSetEnable(trigButton, true) //enable it again.
    endif
endfunction

private function onStateEnter takes nothing returns boolean
    call controller.enable(ControlState.getChangingPlayer(), true)
    return false
endfunction

private function onStateExit takes nothing returns boolean
    local User pId = User[ControlState.getChangingPlayer()]

    call controller.enable(pId.handle, false)
    if effects[pId] != 0 then
        call effects[pId].destroy()
        set effects[pId] = 0
    endif
    return false
endfunction

private function onMoveMouse takes nothing returns boolean
    local integer playerId = User[PlayerEvent_GetTriggerPlayer()]

    if effects[playerId] != 0 then
        set effects[playerId].x = PlayerMouseEvent_GetTriggerPlayerMouseX()
        set effects[playerId].y = PlayerMouseEvent_GetTriggerPlayerMouseY()
    endif
    
    return false
endfunction

private function onMousePress takes nothing returns boolean
    local User playerId = User[PlayerEvent_GetTriggerPlayer()]
    

    if not IsPlayerIdMouseOnButton(playerId) and effects[playerId] != 0 and PlayerMouseEvent_GetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
        call CreateUnit(playerId.handle, effects[playerId].unitType, PlayerMouseEvent_GetTriggerPlayerMouseX(), PlayerMouseEvent_GetTriggerPlayerMouseY(), 0.)
        if not OSKeys.LSHIFT.isPressedId(playerId) and not OSKeys.RSHIFT.isPressedId(playerId) then
            call effects[playerId].destroy()
            set effects[playerId] = 0
        endif
    endif
    
    return false
endfunction

private function onKey takes nothing returns boolean
    local User pId = User[GetTriggerPlayer()]

    if ControlState.getPlayerIdActiveState(pId) == controlState then
        if BlzGetTriggerPlayerKey() == OSKEY_ESCAPE then
            if effects[pId] != 0 then
                call effects[pId].destroy()
                set effects[pId] = 0
            endif
        endif
    endif
    
    return true
endfunction

//===========================================================================
//! runtextmacro Begin0SecondInitializer("Init")
    local trigger trig = CreateTrigger()
    call TriggerAddAction(trig, function onEditText)
    
    call BlzTriggerRegisterFrameEvent(trig, decorationBrowserScreen["editBox"], FRAMEEVENT_EDITBOX_TEXT_CHANGED)
    
    call BlzFrameSetPoint(decorationBrowserScreen["switchButton"], FRAMEPOINT_BOTTOMRIGHT, DecorationsListbox.buttons[0], FRAMEPOINT_TOPRIGHT, 0., 0.)
    call BlzFrameSetPoint(decorationBrowserScreen["editBox"], FRAMEPOINT_BOTTOMLEFT, DecorationsListbox.buttons[0], FRAMEPOINT_TOPLEFT, 0., 0.)
    call BlzFrameSetPoint(decorationBrowserScreen["editBox"], FRAMEPOINT_RIGHT, decorationBrowserScreen["switchButton"], FRAMEPOINT_LEFT, 0., 0.)
    call BlzFrameSetPoint(decorationBrowserScreen["titleText"], FRAMEPOINT_BOTTOMLEFT, decorationBrowserScreen["editBox"], FRAMEPOINT_TOPLEFT, 0, 0)
    call BlzFrameSetPoint(decorationBrowserScreen["titleText"], FRAMEPOINT_BOTTOMRIGHT, decorationBrowserScreen["switchButton"], FRAMEPOINT_TOPRIGHT, 0, 0)
    call BlzFrameSetPoint(decorationBrowserScreen["backdrop"], FRAMEPOINT_TOP, decorationBrowserScreen["titleText"], FRAMEPOINT_TOP, 0., 0.009)
    call BlzFrameSetPoint(decorationBrowserScreen["backdrop"], FRAMEPOINT_RIGHT, DecorationsListbox.scrollBar, FRAMEPOINT_RIGHT, 0., 0.)
    call BlzFrameSetPoint(decorationBrowserScreen["backdrop"], FRAMEPOINT_BOTTOMLEFT, DecorationsListbox.buttons[DecorationsListbox.numberOfEntries-1], FRAMEPOINT_BOTTOMLEFT, -0.008, -0.004)
    
    set trig = CreateTrigger()
    call TriggerAddAction(trig, function onClick)
    call BlzTriggerRegisterFrameEvent(trig, decorationBrowserScreen["switchButton"], FRAMEEVENT_CONTROL_CLICK)
    
    set controller = ScreenController.create(decorationBrowserScreen, null)
    
    set controlState = controlState.create()
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onStateEnter))
    set controlState.onActivate = trig
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onStateExit))
    set controlState.onDeactivate = trig
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onMoveMouse))
    set controlState.trigger[EVENT_PLAYER_MOUSE_MOVE] = trig
    
    set trig = CreateTrigger()
    call TriggerAddCondition(trig, Condition(function onMousePress))
    set controlState.trigger[EVENT_PLAYER_MOUSE_UP] = trig
    
    call OSKeys.LSHIFT.register()
    call OSKeys.RSHIFT.register()
    call OSKeys.ESCAPE.register()
    call OSKeys.addListener(Condition(function onKey))
    
    call IsMouseOnButton_Register(decorationBrowserScreen["switchButton"])
    call IsMouseOnButton_Register(decorationBrowserScreen["editBox"])
    call EditBoxFix_Register(decorationBrowserScreen["editBox"])
//! runtextmacro End0SecondInitializer()

endlibrary