library DecorationBrowserController initializer Init requires Packets, DecorationBrowserView, ListBox, RegisterClassicDecorations, optional LoPUnitCompatibility

//! runtextmacro optional LoPUnitCompatibility()

globals
    private DecorationList array playerLists
    private boolean array isReforged
endglobals


private function onPacket takes nothing returns boolean
    local RealPacket packet = RealPacket.eventPacket

    call CreateUnit(GetTriggerPlayer(), packet.metaData[0], packet[0], packet[1], 270.)

    call packet.destroy()
    return false
endfunction

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
        if isReforged[User.fromLocal()] then
            call BlzFrameSetText(buttons[frameIndex], GetObjectName(ReforgedDecorationList(playerLists[User.fromLocal()])[listIndex]))
        else
            call BlzFrameSetText(buttons[frameIndex], GetObjectName(playerLists[User.fromLocal()][listIndex]))
        endif
    endmethod
    
    static method onCreateFrame takes integer frameIndex returns nothing
        call BlzFrameSetText(buttons[frameIndex], GetObjectName(DecorationList.get("")[frameIndex]))
    endmethod
    
    static method onClickHandler takes player trigP, integer frameIndex, integer listIndex returns nothing
        local User pId = User[trigP]
        local RealPacket packet = RealPacket.create(2, Condition(function onPacket))

        
        set packet[0] = GetCameraTargetPositionX()
        set packet[1] = GetCameraTargetPositionY()

        if isReforged[pId] then
            // call BJDebugMsg(I2S(listIndex) + ": " + GetObjectName(ReforgedDecorationList(playerLists[pId])[listIndex]))
            set packet.metaData[0] = ReforgedDecorationList(playerLists[User[trigP]])[listIndex]
        else
            // call BJDebugMsg(I2S(listIndex) + ": " + GetObjectName(playerLists[pId][listIndex]))
            set packet.metaData[0] = playerLists[User[trigP]][listIndex]
        endif
        
        call packet.sync(trigP)
    endmethod

    implement ListBoxTemplate
endstruct

globals
    public ScreenController controller
endglobals

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
    call RefreshList(User[GetTriggerPlayer()], BlzGetTriggerFrameText())
    return true
endfunction

private function onClick takes nothing returns nothing
    local User pId = User[GetTriggerPlayer()]
    local framehandle trigButton = BlzGetTriggerFrame()
    
    set isReforged[pId] = not isReforged[pId]
    if User.fromLocal() == pId then
        if isReforged[pId] then
            call BlzFrameSetText(decorationBrowserScreen["titleText"], "Reforged Decorations")
        else
            call BlzFrameSetText(decorationBrowserScreen["titleText"], "Classic Decorations")
        endif
        call RefreshList(pId, BlzFrameGetText(decorationBrowserScreen["editBox"]))
    endif
    
    if User.fromLocal() == pId then
        call BlzFrameSetEnable(trigButton, false) //disable the clicked button
        call BlzFrameSetEnable(trigButton, true) //enable it again.
    endif
endfunction

//===========================================================================
private function Init takes nothing returns nothing
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
endfunction

endlibrary