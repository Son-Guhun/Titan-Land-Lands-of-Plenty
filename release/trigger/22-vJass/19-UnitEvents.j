library UnitEvents requires ArgumentStack, BoolExprEvaluator
    /* Simple unit events library by Guhun
    
    These are supposed to be called by the user in their own global unit event triggers.
    
    
    (See System Cleanup Death and System Cleanup Removal triggers in the Map System category).
    */

    struct UnitEvents extends array
        
        //! runtextmacro TableStruct_NewReadonlyStructField("onDeath_impl","BoolExprEvaluator")
        //! runtextmacro TableStruct_NewReadonlyStructField("onRemove_impl","BoolExprEvaluator")
        //! runtextmacro TableStruct_NewReadonlyPrimitiveField("removeOnDeath","boolean")
        
        static method get takes unit whichUnit returns thistype
            return GetHandleId(whichUnit)
        endmethod
        
        method destroy takes nothing returns nothing
            if .onDeath_impl != 0 then
                call .onDeath_impl.destroy()
            endif
            
            if .onRemove_impl != 0 then
                call .onRemove_impl.destroy()
            endif
            
            call .onRemove_implClear()
            call .onDeath_implClear()
            call .removeOnDeathClear()
        endmethod
        
        
        static method getEventUnit takes nothing returns unit
            return Args.unitGet(0)
        endmethod
        
        static method evalOnRemove takes unit whichUnit returns nothing
            if UnitEvents.get(whichUnit).onRemove_impl != 0 then
                call Args.unitSet(0, whichUnit)
                call UnitEvents.get(whichUnit).onRemove.evaluate()
                call Args.unitFree(0)
            endif
            call UnitEvents.get(whichUnit).destroy()
        endmethod
        
        static method evalOnDeath takes unit whichUnit returns nothing
            if UnitEvents.get(whichUnit).onDeath_impl != 0 then
                call Args.unitSet(0, whichUnit)
                call UnitEvents.get(whichUnit).onDeath.evaluate()
                call Args.unitFree(0)
            endif
            if UnitEvents.get(whichUnit).removeOnDeath then
                call UnitEvents.get(whichUnit).evalOnRemove(whichUnit)
                call RemoveUnit(whichUnit)
            endif
        endmethod
        
        
        
        method setRemoveOnDeath takes nothing returns nothing
            set .removeOnDeath = true
        endmethod
        
        
        method operator onDeath takes nothing returns BoolExprEvaluator
            if .onDeath_impl == 0 then
                set .onDeath_impl = BoolExprEvaluator.create()
            endif
            return .onDeath_impl
        endmethod
        method operator onDeath= takes BoolExprEvaluator eval returns nothing
            set .onDeath_impl = eval
        endmethod
        

        method operator onRemove takes nothing returns BoolExprEvaluator
            if .onRemove_impl == 0 then
                set .onRemove_impl = BoolExprEvaluator.create()
            endif
            return .onRemove_impl
        endmethod
        method operator onRemove= takes BoolExprEvaluator eval returns nothing
            set .onRemove_impl = eval
        endmethod
    
    endstruct

endlibrary