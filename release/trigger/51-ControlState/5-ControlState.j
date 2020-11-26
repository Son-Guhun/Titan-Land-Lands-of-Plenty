/*
TODO:

ControlState should have a parent field, which holds a control state. If the current control state
does not have a certain event attached, but has a parent, check the parent for the event. If the 
parent has the event, execute the parent's event. A parent can have a parent.
*/
library ControlState initializer onInit requires TableStruct, SelectionStates, PlayerEvent

globals
    private real array LastMouseX
    private real array LastMouseY
endglobals

function GetPlayerLastMouseX takes player whichPlayer returns real
    return LastMouseX[GetPlayerId(whichPlayer)]
endfunction

function GetPlayerLastMouseY takes player whichPlayer returns real
    return LastMouseY[GetPlayerId(whichPlayer)]
endfunction

private struct Boolexprs extends array
    //! runtextmacro TableStruct_NewStructField("tab","Table")
    
    method operator [] takes eventid e returns boolexpr
        return tab.boolexpr[GetHandleId(e)]
    endmethod
    
    method operator []= takes eventid e, boolexpr callback returns nothing
        set tab.boolexpr[GetHandleId(e)] = callback
    endmethod
    
    method has takes eventid e returns boolean
        return tab.boolexpr.has(GetHandleId(e))
    endmethod
endstruct

struct ControlState extends array
    
    //! runtextmacro TableStruct_NewConstTableField("private","activeStates")
    
    static method getPlayerIdActiveState takes integer playerId returns ControlState
        return activeStates[playerId]
    endmethod

    method operator boolexpr takes nothing returns Boolexprs
        return this
    endmethod
    
    //! runtextmacro TableStruct_NewStructField("selectionState","SelectionState")
    //! runtextmacro TableStruct_NewStructField("dragSelectionState","DragSelectionState")
    //! runtextmacro TableStruct_NewStructField("preSelectionState","PreSelectionState")
    
    //! runtextmacro TableStruct_NewHandleField("onActivate","boolexpr")
    //! runtextmacro TableStruct_NewHandleField("onDeactivate","boolexpr")
    
    static method getChangingPlayer takes nothing returns player
        return Player(Args.s[0])
    endmethod
    
    method activateForPlayer takes player whichPlayer returns nothing
        local integer playerId = GetPlayerId(whichPlayer)
        local ControlState current = activeStates[playerId]
        
        call Args.newStack()
        
        if current.onDeactivate != null then
            set Args.s.integer[0] = playerId
            call CallbackTools_EvaluateBoolexpr(current.onDeactivate)
        endif
        
        if .onActivate != null then
            set Args.s.integer[0] = playerId
            call CallbackTools_EvaluateBoolexpr(.onActivate)
        endif
        
        call Args.s.flush()
        call Args.pop()
        
        set activeStates[playerId] = this
        if GetLocalPlayer() == whichPlayer then
            call .selectionState.apply()
            call .dragSelectionState.apply()
            call .preSelectionState.apply()
        endif
    endmethod

    
    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods
    
    static method operator default takes nothing returns thistype
        return 0
    endmethod
    
    static method create takes nothing returns thistype
        local ControlState this = .allocate()
        
        set Boolexprs(this).tab = Table.create()
        
        return this
    endmethod
    
endstruct

private function onMouseButtonEvent takes nothing returns boolean
    local player triggerPlayer = GetTriggerPlayer()
    local integer playerId = GetPlayerId(triggerPlayer)
    
    if ControlState.getPlayerIdActiveState(playerId).boolexpr.has(GetTriggerEventId()) then
        call PlayerEvent_EvaluateMouseButton(triggerPlayer, /*
                                           */GetTriggerEventId(), /*
                                           */BlzGetTriggerPlayerMouseX(), /*
                                           */BlzGetTriggerPlayerMouseY(), /*
                                           */BlzGetTriggerPlayerMouseButton(), /*
                                           */ControlState.getPlayerIdActiveState(playerId).boolexpr[GetTriggerEventId()])
    endif
    
    set LastMouseX[playerId] = BlzGetTriggerPlayerMouseX()
    set LastMouseY[playerId] = BlzGetTriggerPlayerMouseY()
    return false
endfunction

private function onMouseMoveEvent takes nothing returns boolean
    local player triggerPlayer = GetTriggerPlayer()
    local integer playerId = GetPlayerId(triggerPlayer)
    
    if ControlState.getPlayerIdActiveState(playerId).boolexpr.has(EVENT_PLAYER_MOUSE_MOVE) then
        call PlayerEvent_EvaluateMouseMove(triggerPlayer, /*
                                           */BlzGetTriggerPlayerMouseX(), /*
                                           */BlzGetTriggerPlayerMouseY(), /*
                                           */ControlState.getPlayerIdActiveState(playerId).boolexpr[EVENT_PLAYER_MOUSE_MOVE])
    endif
    
    set LastMouseX[playerId] = BlzGetTriggerPlayerMouseX()
    set LastMouseY[playerId] = BlzGetTriggerPlayerMouseY()
    return false
endfunction

function onStart takes nothing returns nothing
    local integer i = 0
    local trigger onMouseButton = CreateTrigger()
    local trigger onMouseMove = CreateTrigger()
    local trigger onKey = CreateTrigger()
    
    call TriggerAddCondition(onMouseButton, Condition(function onMouseButtonEvent))
    call TriggerAddCondition(onMouseMove, Condition(function onMouseMoveEvent))
    call TriggerAddCondition(onKey, Condition(function onMouseMoveEvent))
    
    loop
    exitwhen i > bj_MAX_PLAYERS
        if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
            call TriggerRegisterPlayerEvent(onMouseButton, Player(i), EVENT_PLAYER_MOUSE_DOWN )
            call TriggerRegisterPlayerEvent(onMouseButton, Player(i), EVENT_PLAYER_MOUSE_UP )
            
            call TriggerRegisterPlayerEvent(onMouseMove, Player(i), EVENT_PLAYER_MOUSE_MOVE )
        endif
        set i = i + 1
    endloop
    
    call PauseTimer(GetExpiredTimer())
    call DestroyTimer(GetExpiredTimer())
endfunction

// Doesn't need to be a module since it doesn't initialize anything that other libraries have access to.
private function onInit takes nothing returns nothing
    call TimerStart(CreateTimer(), 0., false, function onStart)
endfunction

endlibrary