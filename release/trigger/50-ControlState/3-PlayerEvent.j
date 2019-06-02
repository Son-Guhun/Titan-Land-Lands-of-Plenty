library PlayerEvent requires ArgumentStack
/*
This library allows you to evaluate triggers or boolexprs as if they had been set off by a player event.

The main purpose of this library is to simulate player actions using the same triggers that would
normally be run upon a player acting.

To use this library correctly, you must not use the normal "GetTrigger..." natives. Instead, use:
    - PlayerEvent_GetTriggerPlayer()
    - PlayerEvent_GetTriggerPlayerEvent()
    
API:
public function Evaluate takes player whichPlayer, eventid whichEvent, trigger callback returns nothing

public function ExprEvaluate takes player whichPlayer, eventid whichEvent, boolexpr callback returns nothing
*/

globals
    private constant key PLAYER_STACK
    private constant key EVENTID_STACK
endglobals

public function GetTriggerPlayer takes nothing returns player
    return Args.playerGet(PLAYER_STACK)
endfunction

public function GetTriggerPlayerEvent takes nothing returns playerevent
    return ConvertPlayerEvent(Args.integerGet(EVENTID_STACK))
endfunction

public function Evaluate takes player whichPlayer, eventid whichEvent, trigger callback returns nothing
    if whichEvent == null then
        return
    endif

    call Args.playerSet(PLAYER_STACK, whichPlayer)
    call Args.integerSet(EVENTID_STACK, GetHandleId(whichEvent))
    call TriggerEvaluate(callback)
    call Args.playerFree(PLAYER_STACK)
    call Args.integerFree(EVENTID_STACK)
endfunction

public function ExprEvaluate takes player whichPlayer, eventid whichEvent, boolexpr callback returns nothing
    local trigger trig = CreateTrigger()
    call TriggerAddCondition(trig, callback)
    
    call Evaluate(whichPlayer, whichEvent, trig)
    
    call DestroyTrigger(trig)
    set trig = null
endfunction

endlibrary