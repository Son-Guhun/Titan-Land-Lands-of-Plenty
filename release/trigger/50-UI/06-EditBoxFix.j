library EditBoxFix requires Table, OSKeyLib, PlayerUtils
/* 
Version: 1.0.0

Why it's needed:
When typing in an editbox, no mouse events are fired, which means we should call OSKeys.resetKeys()
method in order to avoid issues with tracking which key is currently being held down. Additionally,
when giving an editbox focus using BlzFrameSetFocus, the player may be unable to unfocus the frame
unless they press Esc. So this library also handles this by removing focus from an editbox when the
player clicks anywhere outisde of it in the UI.

How it works:
Track whether mouse is currently in or out of an edit box. When entering an editbox, save it as the 
current one. In a mouse click event, if the mouse is outside of any boxes and current edit box is not
null, remove focus from that editbox. If inside a box, resetKeys then set focus on that box.
*/

globals
    private constant key inside  // Table, stores trigger in key -1, booleans in keys from 0 to max player id
    private constant key frames
endglobals

// Function used for tracking mouse position
private function onEnterLeave takes nothing returns boolean
    local integer pId = GetPlayerId(GetTriggerPlayer())

    if BlzGetTriggerFrameEvent() == FRAMEEVENT_MOUSE_ENTER then
        set Table(inside).boolean[pId] = true
        set Table(frames).framehandle[pId] = BlzGetTriggerFrame()
    else
        call Table(inside).boolean.remove(pId)
    endif
    
    return false
endfunction

// Executed when a player clicks a mouse button. If outisde the chat box, remove focus from it.
private function onWorld takes nothing returns boolean
    local User pId =  GetPlayerId(GetTriggerPlayer())
    
    if Table(frames).handle.has(pId) then
        if Table(inside).boolean.has(pId) then
            call OSKeys.resetKeys(pId)
        else
            if User.fromLocal() == pId then
                call BlzFrameSetFocus(Table(frames).framehandle[pId], false)
            endif
            call Table(frames).handle.remove(pId)
        endif
    endif
    
    return false
endfunction

public function SetPlayerFocusedEditBox takes player whichPlayer, framehandle editBox returns nothing
    set Table(frames).framehandle[User[whichPlayer]] = editBox
endfunction

public function Register takes framehandle whichButton returns nothing
    local trigger trig
    local User pId

    if Table(inside).handle.has(-1) then
        set trig = Table(inside).trigger[-1]
    else
        // Initialization (only run once)
        set trig = CreateTrigger()
        call TriggerAddCondition(trig, Condition(function onWorld))
        
        set pId = 0
        loop
            exitwhen pId >= bj_MAX_PLAYERS
            if GetPlayerSlotState(pId.handle) == PLAYER_SLOT_STATE_PLAYING then
                call TriggerRegisterPlayerEvent(trig, pId.handle, EVENT_PLAYER_MOUSE_DOWN)
            endif
            set pId = pId + 1
        endloop
    
        set trig = CreateTrigger()
        call TriggerAddCondition(trig, Condition(function onEnterLeave))
        set Table(inside).trigger[-1] = trig
    endif

    call BlzTriggerRegisterFrameEvent(trig, whichButton, FRAMEEVENT_MOUSE_ENTER)
    call BlzTriggerRegisterFrameEvent(trig, whichButton, FRAMEEVENT_MOUSE_LEAVE)
endfunction


endlibrary