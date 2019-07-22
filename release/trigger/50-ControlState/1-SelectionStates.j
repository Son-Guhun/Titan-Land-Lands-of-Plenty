library SelectionStates requires TableStruct, GMUI
/*
This library defines the following structs:

    SelectionState (Properties: enabled, circles)
    DragSelectionState (Properties: enabled, box)
    PreSelectionState (Properties: enabled, info)
    
These structs use the EnableSelect, EnableDragSelect and EnablePreSelect natives to change the current
selection state of players. Each struct has a static memeber called 'current', which holds the state
that is currently being applied. Any updates to a property of the current state will immediately take
effect ingame.

For more documentation on the natives, you can create a GUI trigger and read how they work. The related
actions are under the "Game" Action Type.
*/

struct SelectionState extends array
    private static key static_members_key
    private static thistype current = 0

    //! runtextmacro TableStruct_NewPrimitiveField("enabled_impl","boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("circles_impl","boolean")
    
    method operator enabled takes nothing returns boolean
        return .enabled_impl
    endmethod
    
    method operator enabled= takes boolean flag returns nothing
        if thistype.current == this then
            call EnableSelect(flag, .circles)
        endif
        set .enabled_impl = flag
    endmethod
    
    method operator circles takes nothing returns boolean
        return .circles_impl
    endmethod
    
    method operator circles= takes boolean flag returns nothing
        if thistype.current == this then
            call EnableSelect(.enabled, flag)
        endif
        set .circles_impl = flag
    endmethod
    
    method apply takes nothing returns nothing
        set thistype.current = this
        call EnableSelect(.enabled, .circles)
    endmethod
    
    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods
    
    static method operator default takes nothing returns thistype
        return 0
    endmethod
    
    static method create takes nothing returns thistype
        return .allocate()
    endmethod
    
//    method destroy takes nothing returns nothing
//        if thistype.current == this then
//            call thistype.default.apply()
//        endif
//        
//        call .enabled_implClear()
//        call .circles_implClear()
//        call .deallocate()
//    endmethod
endstruct

struct DragSelectionState extends array
    private static key static_members_key
    private static thistype current = 0

    //! runtextmacro TableStruct_NewPrimitiveField("enabled_impl","boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("box_impl","boolean")
    
    method operator enabled takes nothing returns boolean
        return .enabled_impl
    endmethod
    
    method operator enabled= takes boolean flag returns nothing
        if thistype.current == this then
            call EnableDragSelect(flag, .box)
        endif
        set .enabled_impl = flag
    endmethod
    
    method operator box takes nothing returns boolean
        return .box_impl
    endmethod
    
    method operator box= takes boolean flag returns nothing
        if thistype.current == this then
            call EnableDragSelect(.enabled, flag)
        endif
        set .box_impl = flag
    endmethod
    
    method apply takes nothing returns nothing
        set thistype.current = this
        call EnableDragSelect(.enabled, .box)
    endmethod
    
    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods
    
    static method operator default takes nothing returns thistype
        return 0
    endmethod
    
    static method create takes nothing returns thistype
        return .allocate()
    endmethod
    
//    method destroy takes nothing returns nothing
//        if thistype.current == this then
//            call thistype.default.apply()
//        endif
//        
//        call .enabled_implClear()
//        call .box_implClear()
//        call .deallocate()
//    endmethod
endstruct

struct PreSelectionState extends array
    private static key static_members_key
    private static thistype current = 0

    //! runtextmacro TableStruct_NewPrimitiveField("enabled_impl","boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("info_impl","boolean")
    
    method operator enabled takes nothing returns boolean
        return .enabled_impl
    endmethod
    
    method operator enabled= takes boolean flag returns nothing
        if thistype.current == this then
            call EnablePreSelect(flag, .info)
        endif
        set .enabled_impl = flag
    endmethod
    
    method operator info takes nothing returns boolean
        return .info_impl
    endmethod
    
    method operator info= takes boolean flag returns nothing
        if thistype.current == this then
            call EnablePreSelect(.enabled, flag)
        endif
        set .info_impl = flag
    endmethod
    
    method apply takes nothing returns nothing
        set thistype.current = this
        call EnablePreSelect(.enabled, .info)
    endmethod
    
    implement GMUIUseGenericKey
    implement GMUIAllocatorMethods
    
    static method operator default takes nothing returns thistype
        return 0
    endmethod
    
    static method create takes nothing returns thistype
        return .allocate()
    endmethod
    
//    method destroy takes nothing returns nothing
//        if thistype.current == this then
//            call thistype.default.apply()
//        endif
//        
//        call .enabled_implClear()
//        call .info_implClear()
//        call .deallocate()
//    endmethod
endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
        set SelectionState.default.enabled = true
        set SelectionState.default.circles = true
        set DragSelectionState.default.enabled = true
        set DragSelectionState.default.box = true
        set PreSelectionState.default.enabled = true
        set PreSelectionState.default.info = true
    endmethod
endmodule
struct InitStruct extends array
    implement InitModule
endstruct

endlibrary

// In case this should ever be implemented by storing a single integer to use less space than 2 bools
/*
globals
    constant integer SELECTION_ENABLE_CIRCLE_OFF  = 1
    constant integer SELECTION_ENABLE_CIRCLE_ON   = 0
    constant integer SELECTION_DISABLE_CIRCLE_ON  = 10
    constant integer SELECTION_DISABLE_CIRCLE_OFF = 11
    
    constant integer DRAG_ENABLE_BOX_OFF  = 1
    constant integer DRAG_ENABLE_BOX_ON   = 0
    constant integer DRAG_DISABLE_BOX_ON  = 10
    constant integer DRAG_DISABLE_BOX_OFF = 11
    
    constant integer PRE_ENABLE_INFO_OFF  = 1
    constant integer PRE_ENABLE_INFO_ON   = 0
    constant integer PRE_DISABLE_INFO_ON  = 10
    constant integer PRE_DISABLE_INFO_OFF = 11
endglobals
*/