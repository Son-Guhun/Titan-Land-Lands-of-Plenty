library PlayerEvent requires ArgumentStack
/*
This library allows you to evaluate triggers or boolexprs as if they had been set off by a player event.

The main purpose of this library is to simulate player actions using the same triggers that would
normally be run upon a player acting.

To use this library correctly, you must not use the normal "GetTrigger..." natives. Instead, use:
    - PlayerEvent_GetTriggerPlayer()
    - PlayerEvent_GetTriggerPlayerEvent()
    - PlayerEvent_GetTriggerPlayerMouseX()
    - PlayerEvent_GetTriggerPlayerMouseY()
    - PlayerEvent_GetTriggerPlayerMouseButton()
    
API:
public function Evaluate takes player whichPlayer, eventid whichEvent, trigger callback returns nothing

public function ExprEvaluate takes player whichPlayer, eventid whichEvent, boolexpr callback returns nothing

public function EvaluateMouseMove takes player whichPlayer, real x, real y, trigger callback returns nothing

public function EvaluateMouseButton takes player whichPlayer, eventid whichEvent, real x, real y, mousebuttontype whichButton, trigger callback returns nothing
*/

private struct Args extends array

    implement ArgumentStack
    
    static method operator s takes nothing returns Table
        return stack
    endmethod

endstruct

globals
    private constant integer PLAYER_STACK = 0
    private constant integer EVENT_STACK  = 1
    private constant integer X_STACK      = 2
    private constant integer Y_STACK      = 3
    private constant integer BUTTON_STACK = 4
endglobals

public function GetTriggerPlayer takes nothing returns player
    return Args.s.player[PLAYER_STACK]
endfunction

public function GetTriggerPlayerEvent takes nothing returns playerevent
    return ConvertPlayerEvent(Args.s.integer[EVENT_STACK])
endfunction

public function GetTriggerPlayerMouseX takes nothing returns real
    return Args.s.real[X_STACK]
endfunction

public function GetTriggerPlayerMouseY takes nothing returns real
    return Args.s.real[Y_STACK]
endfunction

public function GetTriggerPlayerMouseButton takes nothing returns mousebuttontype
    return ConvertMouseButtonType(Args.s.integer[BUTTON_STACK])
endfunction

private function EvaluateEx takes player whichPlayer, eventid whichEvent, trigger callback, boolean createStack returns nothing
    if whichEvent == null then
        return
    endif
    
    if createStack then
        call Args.newStack()
    endif
    set Args.s.player[PLAYER_STACK] = whichPlayer
    set Args.s.integer[EVENT_STACK] = GetHandleId(whichEvent)
    call TriggerEvaluate(callback)
    call Args.s.flush()
    call Args.pop()
endfunction

public function Evaluate takes player whichPlayer, eventid whichEvent, trigger callback returns nothing
    call EvaluateEx(whichPlayer, whichEvent, callback, true)
endfunction

public function EvaluateMouseMove takes player whichPlayer, real x, real y, trigger callback returns nothing

    call Args.newStack()
    set Args.s.real[X_STACK] = x
    set Args.s.real[Y_STACK] = y
    call EvaluateEx(whichPlayer, EVENT_PLAYER_MOUSE_MOVE, callback, false)
endfunction

public function EvaluateMouseButton takes player whichPlayer, eventid whichEvent, real x, real y, mousebuttontype whichButton, trigger callback returns nothing
    if whichButton == null then
        return
    endif
    
    if whichEvent == EVENT_PLAYER_MOUSE_DOWN or whichEvent == EVENT_PLAYER_MOUSE_UP then
        call Args.newStack()
        set Args.s.integer[BUTTON_STACK] = IMinBJ(GetHandleId(whichButton), 3)  // Why IMin? Cuz GetHandleId(MOUSE_BUTTON_tYPE_RIGHT) returns 4, not 3.
        set Args.s.real[X_STACK] = x
        set Args.s.real[Y_STACK] = y
        call EvaluateEx(whichPlayer, whichEvent, callback, false)
    endif
endfunction


endlibrary