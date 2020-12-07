library CallbackTools
/*

    Defines the EvaluateBoolexpr and ExecuteCode functions. Used for executing callbacks without having
to add them to a trigger first.

*/

globals
    private force ENUM_FORCE = CreateForce()
endglobals

public function EvaluateBoolexpr takes boolexpr callback returns nothing
    local trigger trig = CreateTrigger()
    call TriggerAddCondition(trig, callback)
    call TriggerEvaluate(trig)
    call DestroyTrigger(trig)
    set trig = null
endfunction

public function ExecuteCode takes code callback returns nothing
    call ForForce(bj_FORCE_PLAYER[0], callback)
endfunction


endlibrary