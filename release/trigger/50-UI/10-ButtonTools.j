library ButtonTools requires TableStruct, OOP, ArgumentStack, CallbackTools

private struct FrameButton extends array

    implement ArgumentStack

    //! runtextmacro OOP_HandleStruct("framehandle")
    
    //! runtextmacro TableStruct_NewHandleField("callback", "boolexpr")
    
    private static key static_members_key
    //! runtextmacro TableStruct_NewStaticHandleField("eventHandler", "trigger")
    
    method hasCallback takes nothing returns boolean
        return callbackExists()
    endmethod
    
    static method isInitialized takes nothing returns boolean
        return eventHandlerExists()
    endmethod

endstruct

public function GetTriggerPlayer takes nothing returns player
    return FrameButton.stack.player[0]
endfunction

public function GetTriggerFrame takes nothing returns framehandle
    return FrameButton.stack.framehandle[1]
endfunction

public function ClickButton takes player whichPlayer, framehandle buttonFrame returns nothing
    if FrameButton[buttonFrame].hasCallback() then
        call FrameButton.newStack()
        set FrameButton.stack.player[0] = whichPlayer
        set FrameButton.stack.framehandle[1] = buttonFrame
        
        call CallbackTools_EvaluateBoolexpr(FrameButton[buttonFrame].callback)
        
        call FrameButton.stack.flush()
        call FrameButton.pop()
    endif
endfunction

private function onClick takes nothing returns boolean
    call ClickButton(GetTriggerPlayer(), BlzGetTriggerFrame())
    return false
endfunction

public function ButtonFrameAttachBoolexpr takes framehandle buttonFrame, boolexpr expr returns nothing
    if not FrameButton.isInitialized() then
        set FrameButton.eventHandler = CreateTrigger()
        call TriggerAddCondition(FrameButton.eventHandler, Condition(function onClick))
    endif
    
    // Only register event if the frame didn't have an attached callback before
    if FrameButton[buttonFrame].hasCallback() and expr != null then
        call BlzTriggerRegisterFrameEvent(FrameButton.eventHandler, buttonFrame, FRAMEEVENT_CONTROL_CLICK)
    endif
    set FrameButton[buttonFrame].callback = expr
endfunction



endlibrary