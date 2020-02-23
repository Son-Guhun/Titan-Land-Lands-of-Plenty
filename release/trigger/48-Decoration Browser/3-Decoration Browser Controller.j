library DecorationBrowserController initializer Init requires DecorationBrowserView, ListBox, RegisterDecorationNames, optional LoPUnitCompatibility

//! runtextmacro optional LoPUnitCompatibility()

globals
    private DecorationList array playerLists
endglobals

struct DecorationsListbox extends array
    static constant framepointtype startFramepoint = FRAMEPOINT_RIGHT
    static constant real startPointX = 0.78
    static constant real startPointY = 0.530
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
        call BlzFrameSetText(buttons[frameIndex], GetObjectName(playerLists[User.fromLocal()][listIndex]))
    endmethod
    
    static method onCreateFrame takes integer frameIndex returns nothing
        call BlzFrameSetText(buttons[frameIndex], GetObjectName(DecorationList.get("")[frameIndex]))
    endmethod
    
    static method onClickHandler takes player trigP, integer frameIndex, integer listIndex returns nothing
        call BJDebugMsg(I2S(listIndex) + ": " + GetObjectName(playerLists[User[trigP]][listIndex]))
        call CreateUnit(trigP, playerLists[User[trigP]][listIndex], 0., 0., 270.)
    endmethod

    implement ListBoxTemplate
endstruct

globals
    public ScreenController controller
endglobals

private function onEditText takes nothing returns boolean
    local player trigP = GetTriggerPlayer()
    local DecorationList list = DecorationList.get(BlzGetTriggerFrameText())
    
    call BJDebugMsg("a")
    set playerLists[User[trigP]] = list
    call DecorationsListbox.changeSize(GetTriggerPlayer(), list.size - 1)
    
    return true
endfunction

//===========================================================================
private function Init takes nothing returns nothing
    local trigger trig = CreateTrigger()
    call TriggerAddAction(trig, function onEditText)
    
    call BlzTriggerRegisterFrameEvent(trig, decorationBrowserScreen["editBox"], FRAMEEVENT_EDITBOX_TEXT_CHANGED)
    
    call BlzFrameSetPoint(decorationBrowserScreen["editBox"], FRAMEPOINT_BOTTOMLEFT, DecorationsListbox.buttons[0], FRAMEPOINT_TOPLEFT, 0., 0.)
    call BlzFrameSetPoint(decorationBrowserScreen["editBox"], FRAMEPOINT_BOTTOMRIGHT, DecorationsListbox.buttons[0], FRAMEPOINT_TOPRIGHT, 0., 0.)
    call BlzFrameSetPoint(decorationBrowserScreen["backdrop"], FRAMEPOINT_TOP, decorationBrowserScreen["editBox"], FRAMEPOINT_TOP, 0., 0.006)
    call BlzFrameSetPoint(decorationBrowserScreen["backdrop"], FRAMEPOINT_RIGHT, DecorationsListbox.scrollBar, FRAMEPOINT_RIGHT, 0., 0.)
    call BlzFrameSetPoint(decorationBrowserScreen["backdrop"], FRAMEPOINT_BOTTOMLEFT, DecorationsListbox.buttons[DecorationsListbox.numberOfEntries-1], FRAMEPOINT_BOTTOMLEFT, -0.008, -0.004)
    
    set controller = ScreenController.create(decorationBrowserScreen, null)
endfunction

endlibrary