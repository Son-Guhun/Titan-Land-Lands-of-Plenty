library PlayerEventTools requires TableStruct
/*
Contains O(1) methods to determine whether an eventid is a mouse event or arrow key event.

API:
function IsEventMouseEvent takes eventid whichEvent returns boolean

function IsEventArrowEvent takes eventid whichEvent returns boolean

function IsEventArrowDownEvent takes eventid whichEvent returns boolean

function IsEventArrowUpEvent takes eventid whichEvent returns boolean
*/

// Internal Struct Implementation
// ========================
private struct PlayerEvent extends array
    //! runtextmacro TableStruct_NewPrimitiveField("isMouseEvent","boolean")
    
    //! runtextmacro TableStruct_NewPrimitiveField("isArrowKeyEvent","boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("isArrowKeyDownEvent","boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("isArrowKeyUpEvent","boolean")
    
    static method get takes eventid whichEvent returns PlayerEvent
        return GetHandleId(whichEvent)
    endmethod
endstruct

// API
// ========================
function IsEventMouseEvent takes eventid whichEvent returns boolean
    return PlayerEvent.get(whichEvent).isMouseEvent
endfunction

function IsEventArrowEvent takes eventid whichEvent returns boolean
    return PlayerEvent.get(whichEvent).isArrowKeyEvent
endfunction

function IsEventArrowDownEvent takes eventid whichEvent returns boolean
    return PlayerEvent.get(whichEvent).isArrowKeyDownEvent
endfunction

function IsEventArrowUpEvent takes eventid whichEvent returns boolean
    return PlayerEvent.get(whichEvent).isArrowKeyUpEvent
endfunction

// Initialization
// ========================
private module InitModule
    private static method onInit takes nothing returns nothing
        local PlayerEvent e
        
        // Mouse Events
        set PlayerEvent.get(EVENT_PLAYER_MOUSE_MOVE).isMouseEvent = true
        set PlayerEvent.get(EVENT_PLAYER_MOUSE_UP).isMouseEvent = true
        set PlayerEvent.get(EVENT_PLAYER_MOUSE_DOWN).isMouseEvent = true
        
        
        // Arrow Down Events
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_LEFT_DOWN)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyDownEvent = true
        
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_DOWN_DOWN)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyDownEvent = true
        
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_RIGHT_DOWN)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyDownEvent = true
        
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_UP_DOWN)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyDownEvent = true
        
        
        // Arrow Up Events
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_LEFT_UP)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyUpEvent = true
        
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_DOWN_UP)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyUpEvent = true
        
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_RIGHT_UP)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyUpEvent = true
        
        set e = PlayerEvent.get(EVENT_PLAYER_ARROW_UP_UP)
        set e.isArrowKeyEvent = true
        set e.isArrowKeyUpEvent = true
    endmethod
endmodule
private struct InitStruct extends array
    implement InitModule
endstruct

endlibrary