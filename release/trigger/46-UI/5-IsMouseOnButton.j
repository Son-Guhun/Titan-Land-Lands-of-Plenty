library IsMouseOnButton requires Table

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