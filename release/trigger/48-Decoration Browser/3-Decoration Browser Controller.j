library DecorationBrowserController requires UpgradeSystem, DecorationBrowserView, ListBox, RegisterClassicDecorations, SpecialEffect, ControlState, IsMouseOnButton, EditBoxFix, optional LoPUnitCompatibility

//! runtextmacro optional LoPUnitCompatibility()

globals
    private DecorationList array playerLists
    private boolean array isReforged
    private key searchStrings  // table of search strings for each player. Used so RefreshList can be used when a player swaps lists, instead of having to fire an editbox event.
endglobals

globals
    public ScreenController controller
    public ControlState controlState
    private SpecialEffect array effects
    private group array selectedUnits
    private integer array variation
endglobals

struct DecorationsListbox extends array
    static constant framepointtype startFramepoint = FRAMEPOINT_RIGHT
    static constant real startPointX = .9 // 0.78
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

    // this code is async
    static method updateFrame takes integer frameIndex, integer listIndex returns nothing
        local integer typeId
        
        if isReforged[User.fromLocal()] then
            set typeId = ReforgedDecorationList(playerLists[User.fromLocal()])[listIndex]
        else
            set typeId = playerLists[User.fromLocal()][listIndex]
        endif
        
        if typeId != 0 then
            // can typecast directly to UpgradeList because the unittype will always be the first in an upgrade list
            if UpgradeData(typeId).hasUpgrades() then
                set typeId = UpgradeList(typeId)[IMinBJ(variation[User.fromLocal()], UpgradeList(typeId).size-1)]
            endif
                
        
            if effects[User.fromLocal()] != 0 and typeId == effects[User.fromLocal()].unitType then
                call BlzFrameSetEnable(buttons[frameIndex], false)
            else
                call BlzFrameSetEnable(buttons[frameIndex], true)
            endif
            call BlzFrameSetText(buttons[frameIndex], GetObjectName(typeId))
        else
            call BlzFrameSetText(buttons[frameIndex], "")
        endif
    endmethod
    
    static method onCreateFrame takes integer frameIndex returns nothing
        call BlzFrameSetText(buttons[frameIndex], GetObjectName(DecorationList.get("")[frameIndex]))
        call IsMouseOnButton_Register(buttons[frameIndex])
    endmethod
    
    static method onClickHandler takes player trigP, integer frameIndex, integer listIndex returns boolean
        local User pId = User[trigP]
        local integer unitType
        
        if ControlState.getPlayerIdActiveState(pId) == ControlState.default then
            call controlState.activateForPlayer(trigP)
        endif
            
        if ControlState.getPlayerIdActiveState(pId) == controlState then
            if effects[pId] != 0 then
                call effects[pId].destroy()
            endif
        
            if isReforged[pId] then
                set unitType = ReforgedDecorationList(playerLists[User[trigP]])[listIndex]
            else
                set unitType = playerLists[User[trigP]][listIndex]
            endif
            
            // can typecast directly to UpgradeList because the unittype will always be the first in an upgrade list
            if UpgradeData(unitType).hasUpgrades() then
                set unitType = UpgradeList(unitType)[IMinBJ(variation[pId], UpgradeList.get(unitType).size - 1)]
            endif
            
            set effects[pId] = SpecialEffect.create(unitType, GetPlayerLastMouseX(trigP), GetPlayerLastMouseY(trigP))
            
            set effects[pId].alpha = 128
            return true
        endif
        
        return false
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

private function onButton takes nothing returns nothing
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

private function onControllerEnable takes nothing returns boolean
    //! runtextmacro ScreenControllerOnEnableArguments("contrl", "whichPlayer", "enable")
    
    if not enable and ControlState.getPlayerIdActiveState(User[whichPlayer]) == controlState then
        call ControlState.default.activateForPlayer(whichPlayer)
    endif
    return false
endfunction

private function onStateEnter takes nothing returns boolean
    local User pId = User[ControlState.getChangingPlayer()]
    
    
    call GroupEnumUnitsSelected(selectedUnits[pId], pId.handle, null)
    return false
endfunction

private function onStateExit takes nothing returns boolean
    local User pId = User[ControlState.getChangingPlayer()]

    call SelectGroupForPlayerBJ(selectedUnits[pId], pId.handle)
    call GroupClear(selectedUnits[pId])
    if effects[pId] != 0 then
        call effects[pId].destroy()
        set effects[pId] = 0
    endif
    call DecorationsListbox.refreshList(pId.handle)  // refresh list to re-enable button, if it's still in the listbox
    return false
endfunction

private function onMoveMouse takes nothing returns boolean
    local integer playerId = User[PlayerEvent_GetTriggerPlayer()]

    if effects[playerId] != 0 then
        call effects[playerId].setPosition(PlayerMouseEvent_GetTriggerPlayerMouseX(), PlayerMouseEvent_GetTriggerPlayerMouseY())
    endif
    
    return false
endfunction

private function onMousePress takes nothing returns boolean
    local User playerId = User[PlayerEvent_GetTriggerPlayer()]
    
    if PlayerMouseEvent_GetTriggerPlayerMouseX() == 0. and PlayerMouseEvent_GetTriggerPlayerMouseY() == 0. then
        // do nothing
    else
        if not IsPlayerIdMouseOnButton(playerId) and effects[playerId] != 0 and PlayerMouseEvent_GetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
            call CreateUnit(playerId.handle, effects[playerId].unitType, PlayerMouseEvent_GetTriggerPlayerMouseX(), PlayerMouseEvent_GetTriggerPlayerMouseY(), 0.)
            if not OSKeys.LSHIFT.isPressedId(playerId) and not OSKeys.RSHIFT.isPressedId(playerId) then
                call ControlState.default.activateForPlayer(playerId.handle)
            endif
        endif
    endif
    
    return false
endfunction

private function onKey takes nothing returns boolean
    local User pId = User[GetTriggerPlayer()]
    local OSKeys key = GetHandleId(BlzGetTriggerPlayerKey())
    local integer unitType

    if ControlState.getPlayerIdActiveState(pId) == controlState then
        if key == OSKeys.ESCAPE then
            call ControlState.default.activateForPlayer(pId.handle)
        endif
    endif
    
    if controller.isEnabled(pId.handle) then
        if key >= OSKeys.KEY0 and key <= OSKeys.KEY9 and BlzGetTriggerPlayerIsKeyDown() then
            set key = key - OSKeys.KEY0 - 1
            if key == -1 then
                set key = 9
            endif
            set variation[pId] = key
            call BJDebugMsg(I2S(variation[pId]))
            if effects[pId] != 0 then
                set unitType = effects[pId].unitType
                
                if UpgradeData(unitType).hasUpgrades() then
                    set key = IMinBJ(variation[pId], UpgradeList.get(unitType).size - 1)
                
                    call effects[pId].destroy()
                    set effects[pId] = SpecialEffect.create(UpgradeList.get(unitType)[key], GetPlayerLastMouseX(pId.handle), GetPlayerLastMouseY(pId.handle))
                    set effects[pId].alpha = 128
                endif
            endif
            call DecorationsListbox.refreshList(pId.handle)
        endif
    endif
    
    return true
endfunction

//===========================================================================
//! runtextmacro Begin0SecondInitializer("Init")
    local trigger trig = CreateTrigger()
    local User pId = 0
    
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
    
    call BlzFrameSetPoint(DecorationsListbox.buttons[0], FRAMEPOINT_RIGHT, UIView.RIGHT_BORDER, FRAMEPOINT_BOTTOMLEFT, -0.02, 0.510)
    
    loop
        exitwhen pId >= bj_MAX_PLAYERS
        if GetPlayerSlotState(pId.handle) == PLAYER_SLOT_STATE_PLAYING then
            set selectedUnits[pId] = CreateGroup()
        endif
        set pId = pId + 1
    endloop
    
    set trig = CreateTrigger()
    call TriggerAddAction(trig, function onButton)
    call BlzTriggerRegisterFrameEvent(trig, decorationBrowserScreen["switchButton"], FRAMEEVENT_CONTROL_CLICK)
    
    set controller = ScreenController.create(decorationBrowserScreen, null)
    set controller.onEnable = Condition(function onControllerEnable)
    
    set controlState = controlState.create()
    set controlState.selectionState = SelectionState.create()
    set controlState.dragSelectionState = DragSelectionState.create()
    set controlState.preSelectionState = PreSelectionState.create()
    
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
    call OSKeys.KEY1.register()
    call OSKeys.KEY2.register()
    call OSKeys.KEY3.register()
    call OSKeys.KEY4.register()
    call OSKeys.KEY5.register()
    call OSKeys.KEY6.register()
    call OSKeys.KEY7.register()
    call OSKeys.KEY8.register()
    call OSKeys.KEY9.register()
    call OSKeys.KEY0.register()
    call OSKeys.addListener(Condition(function onKey))
    
    call IsMouseOnButton_Register(decorationBrowserScreen["switchButton"])
    call IsMouseOnButton_Register(decorationBrowserScreen["editBox"])
    call EditBoxFix_Register(decorationBrowserScreen["editBox"])
//! runtextmacro End0SecondInitializer()

endlibrary