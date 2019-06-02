library PlayerMouseEvent requires PlayerEvent
/*
This library allows you to evaluate triggers or boolexprs as if they had been set off by a player event.

The main purpose of this library is to simulate player actions using the same triggers that would
normally be run upon a player acting.

To use this library correctly, you must not use the normal "GetTrigger..." natives. Instead, use:
    - PlayerEvent_GetTriggerPlayerMouseX()
    - PlayerEvent_GetTriggerPlayerMouseY()
    - PlayerEvent_GetTriggerPlayerMouseButton()
    
API:
public function EvaluateMove takes player whichPlayer, real x, real y, trigger callback returns nothing

public function ExprEvaluateMove takes player whichPlayer, real x, real y, boolexpr callback returns nothing

public function EvaluateButton takes player whichPlayer, eventid whichEvent, real x, real y, mousebuttontype whichButton, trigger callback returns nothing

public function ExprEvaluateButton takes player whichPlayer, eventid whichEvent, real x, real y, mousebuttontype whichButton, boolexpr callback returns nothing
*/

globals
    private constant key X_STACK
    private constant key Y_STACK
endglobals

public function GetTriggerPlayerMouseX takes nothing returns real
    return Args.realGet(X_STACK)
endfunction

public function GetTriggerPlayerMouseY takes nothing returns real
    return Args.realGet(Y_STACK)
endfunction

public function EvaluateMove takes player whichPlayer, real x, real y, trigger callback returns nothing

    call Args.realSet(X_STACK, x)
    call Args.realSet(Y_STACK, y)
    call PlayerEvent_Evaluate(whichPlayer, EVENT_PLAYER_MOUSE_MOVE, callback)
    call Args.realFree(X_STACK)
    call Args.realFree(Y_STACK)
endfunction

public function ExprEvaluateMove takes player whichPlayer, real x, real y, boolexpr callback returns nothing
    local trigger trig = CreateTrigger()
    call TriggerAddCondition(trig, callback)
    
    call EvaluateMove(whichPlayer, x, y, trig)
    
    call DestroyTrigger(trig)
    set trig = null
endfunction

globals
    private constant key BUTTON_STACK
endglobals

public function GetTriggerPlayerMouseButton takes nothing returns mousebuttontype
    return ConvertMouseButtonType(Args.integerGet(BUTTON_STACK))
endfunction

public function EvaluateButton takes player whichPlayer, eventid whichEvent, real x, real y, mousebuttontype whichButton, trigger callback returns nothing
    if whichButton == null then
        return
    endif
    
    if whichEvent == EVENT_PLAYER_MOUSE_DOWN or whichEvent == EVENT_PLAYER_MOUSE_UP then
        call Args.integerSet(BUTTON_STACK, IMinBJ(GetHandleId(whichButton), 3))  // Why IMin? Cuz GetHandleId(MOUSE_BUTTON_tYPE_RIGHT) returns 4, not 3.
        call Args.realSet(X_STACK, x)
        call Args.realSet(Y_STACK, y)
        call PlayerEvent_Evaluate(whichPlayer, whichEvent, callback)
        call Args.realFree(X_STACK)
        call Args.realFree(Y_STACK)
        call Args.integerFree(BUTTON_STACK)
    endif
endfunction

public function ExprEvaluateButton takes player whichPlayer, eventid whichEvent, real x, real y, mousebuttontype whichButton, boolexpr callback returns nothing
    local trigger trig = CreateTrigger()
    call TriggerAddCondition(trig, callback)
    
    call EvaluateButton(whichPlayer, whichEvent, x, y, whichButton, trig)
    
    call DestroyTrigger(trig)
    set trig = null
endfunction




endlibrary