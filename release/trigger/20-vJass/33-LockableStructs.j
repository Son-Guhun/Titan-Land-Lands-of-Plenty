
struct LockableStructs extends array
    readonly static boolean timerStarted = false
    private static timer t = CreateTimer()
    private static thistype array registered
    private static integer total
    
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("pLock", "integer", "LOCK_INDEX")
    //! runtextmacro TableStruct_NewReadonlyAgentField("onCleanup", "boolexpr", "CLEANUP_INDEX")
    
    static method onTimer takes nothing returns nothing
        local integer i = 0
        local thistype object
        
        loop
            exitwhen i >= total
            set object = registered[i]
            
            if object.pLock <= 0 then
                if object.onCleanup != null then
                    call object.onCleanup.evaluate()
                endif
                call object.clearTable()
            endif
            
            set i = i + 1
        endloop
        
        set .timerStarted = false
        set .total = 0
    endmethod
    
    static method register takes thistype object returns nothing
        set total = total + 1
        set registered[total] = 0
    endmethod

    static method startTimer takes nothing returns nothing
        if not .timerStarted then
            call TimerStart(t, 0., false, function thistype.onTimer)
            set .timerStarted = true
        endif
    endmethod
endstruct

module Lockable extends array
    //! runtextmacro TableStruct_NewReadonlyPrimitiveField("pLock", "integer")
    //! runtextmacro TableStruct_NewReadonlyHandleField("onCleanup", "boolexpr", "CLEANUP_INDEX")
    
    method unlock takes nothing returns nothing
        local integer v
        if this.pLockExists() then
            set v = .pLock
            set v = v-1
            if v <= 0 then
                if this.onCleanup != null then
                    call this.onCleanup.evaluate()
                endif
                call this.clearTable()
            else
                set .pLock = v
            endif
        endif
        
    endmethod
endmodule

module Lockable_NoCleanup
    static method operator CLEANUP takes nothing returns boolexpr
        return null
    endmethod

    implement Lockable
endmodule

module Lockable_onCreateLocked
    if thistype.CLEANUP != null then
        set this.onCleanup = thistype.CLEANUP
    endif
    set this.pLock = 0
endmodule

module Lockable_onCreate
    implement Lockable_onCreateLocked
    
    call LockableStructs.register(this)
    if not LockableStructs.timerStarted then
        call LockableStructs.startTimer()
    endif
    
endmodule