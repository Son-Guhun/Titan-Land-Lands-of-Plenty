library BoolExprEvaluator requires TableStruct
globals
    public constant boolean SAFETY = true
endglobals

struct BoolExprEvaluator extends array

    //! runtextmacro TableStruct_NewReadonlyStructField("tab", "Table")
    //! runtextmacro TableStruct_NewReadonlyHandleField("trigger", "trigger")
    // //! runtextmacro TableStruct_NewReadonlyStructField("exprs", "LinkedHashSet")
    
    method hasRegistered takes boolexpr expr returns boolean
        return .tab.handle.has(GetHandleId(expr))
    endmethod
    
    method isNullPointer takes nothing returns boolean
        return .trigger == null
    endmethod
    
    method register takes boolexpr expr returns nothing
        static if SAFETY then
            if .hasRegistered(expr) then
                return
            endif
        endif
        
        set .tab.triggercondition[GetHandleId(expr)] = TriggerAddCondition(.trigger, expr)
    endmethod
    
    method deregister takes boolexpr expr returns nothing
        static if SAFETY then
            if not .hasRegistered(expr) then
                return 
            endif
        endif
        
        call TriggerRemoveCondition(.trigger, .tab.triggercondition[GetHandleId(expr)])
        call .tab.handle.remove(GetHandleId(expr))
    endmethod
    
    method evaluate takes nothing returns nothing
        call TriggerEvaluate(.trigger)
    endmethod
    
    static method create takes nothing returns BoolExprEvaluator
        local trigger trig = CreateTrigger()
        local integer this = GetHandleId(trig)
        
        set .trigger = trig
        set .tab = Table.create()
        set trig = null
        return this
    endmethod
    
    method destroy takes nothing returns nothing
        static if SAFETY then
            if .isNullPointer() then
                return
            endif
        endif
        
        //call TriggerClearConditions(.trigger)
        call DestroyTrigger(.trigger)
        call .tab.destroy()
        call tabClear()
        call triggerClear()
    endmethod

endstruct


endlibrary