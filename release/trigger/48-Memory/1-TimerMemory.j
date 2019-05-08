library TimerMemory requires TableStruct

private struct TimerData extends array
    private static key static_members_key

    //! runtextmacro TableStruct_NewStaticPrimitiveField("totalTimers","integer")
    
//    //! runtextmacro TableStruct_NewPrimitiveField("created","boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("started","boolean")
    //! runtextmacro TableStruct_NewPrimitiveField("paused","boolean")
    
    static method get takes timer t returns TimerData
        return GetHandleId(t)
    endmethod
    
    method destroy takes nothing returns nothing
        call .startedClear()
        call .pausedClear()
        // .createdClear()
    endmethod
endstruct

private function CreateTimerHook takes nothing returns nothing
    set TimerData.totalTimers = TimerData.totalTimers + 1
    call BJDebugMsg("Created a timer. Total: " + I2S(TimerData.totalTimers))
endfunction

private function TimerStartHook takes timer t, real timeout, boolean periodic, code handlerFunc returns nothing
    set TimerData.get(t).started = true
endfunction

private function PauseTimerHook takes timer t returns nothing
    set TimerData.get(t).paused = true
endfunction

private function DestroyTimerHook takes timer t returns nothing
    local TimerData tData = TimerData.get(t)

    if t == null then
        call BJDebugMsg("Attempted to destroy a null timer.")
        return
    endif
    
    if not tData.started then
        call BJDebugMsg("Destroyed a timer that was never created.")
    endif
    
    if not tData.paused then
        call BJDebugMsg("Destroyed a timer that was not paused")
    endif
    
    set TimerData.totalTimers = TimerData.totalTimers - 1

    call tData.destroy()
    call BJDebugMsg("Destroyed timer " + I2S(GetHandleId(t)))
endfunction

hook CreateTimer CreateTimerHook
hook TimerStart TimerStartHook
hook PauseTimer PauseTimerHook  
hook DestroyTimer DestroyTimerHook


endlibrary