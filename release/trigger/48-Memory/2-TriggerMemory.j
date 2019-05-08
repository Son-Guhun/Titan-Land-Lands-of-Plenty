library TriggerMemory requires TableStruct

private struct TriggerData extends array
    private static key static_members_key

    //! runtextmacro TableStruct_NewStaticPrimitiveField("totalTriggers","integer")
    
    static method get takes trigger t returns TriggerData
        return GetHandleId(t)
    endmethod
    
    method destroy takes nothing returns nothing
    endmethod
endstruct

private function CreateTriggerHook takes nothing returns nothing
    set TriggerData.totalTriggers = TriggerData.totalTriggers + 1
    call BJDebugMsg("Created a trigger. Total: " + I2S(TriggerData.totalTriggers))
endfunction

private function DestroyTriggerHook takes trigger t returns nothing
    local TriggerData tData = TriggerData.get(t)

    if t == null then
        call BJDebugMsg("Attempted to destroy a null trigger.")
        return
    endif
    
    set TriggerData.totalTriggers = TriggerData.totalTriggers - 1

    call tData.destroy()
    call BJDebugMsg("Destroyed trigger " + I2S(GetHandleId(t)))
    set t = null
endfunction

hook CreateTrigger CreateTriggerHook
hook DestroyTrigger DestroyTriggerHook


endlibrary