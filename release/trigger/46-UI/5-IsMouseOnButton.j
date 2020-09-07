library IsMouseOnButton requires Table
/* 
Version: 1.0.0

Why it's needed:
When working with systems that depend on user mouse input, a lot of the time we won't want to respond
to mouse click events when a player is clicking on a button. This library tracks whether the player's mouse
is over a registered button so this input can be filtered.

How to use it:
Simply call IsPlayerMouseOnButton(player p) or IsPlayerIdMouseOnButton(integer pId) to check whether
the mouse is over a frame. Usually this will be used when responding to a mouse click event, so you
can avoid responding to the event if the player was clicking on a button. To register a frame, use
IsMouseOnButton_Register(frame f).

How it works:
Track whether mouse is currently in or out of a registered frame. This system uses a constant Table
in order to avoid having to create an array variable.
*/

globals
    private constant key tab  // Table, stores trigger in key -1, booleans in keys from 0 to max player id
endglobals

private function Callback takes nothing returns boolean
    if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
        set Table(tab).boolean[GetPlayerId(GetTriggerPlayer())] = true
    else
        call Table(tab).boolean.remove(GetPlayerId(GetTriggerPlayer()))
    endif
    return false
endfunction

public function Register takes framehandle whichButton returns nothing
    local trigger trig

    // Check if initialization is necessary
    if Table(tab).handle.has(-1) then
        set trig = Table(tab).trigger[-1]
    else
        set trig = CreateTrigger()
        call TriggerAddCondition(trig, Condition(function Callback))
        set Table(tab).trigger[-1] = trig
    endif

    call BlzTriggerRegisterFrameEvent(trig, whichButton, FRAMEEVENT_MOUSE_ENTER)
    call BlzTriggerRegisterFrameEvent(trig, whichButton, FRAMEEVENT_MOUSE_LEAVE)
endfunction

function IsPlayerIdMouseOnButton takes integer pId returns boolean
    return Table(tab).boolean.has(pId)
endfunction

function IsPlayerMouseOnButton takes player whichPlayer returns boolean
    return Table(tab).boolean.has(GetPlayerId(whichPlayer))
endfunction

endlibrary