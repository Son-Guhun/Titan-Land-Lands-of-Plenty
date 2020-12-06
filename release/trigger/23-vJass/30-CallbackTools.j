library CallbackTools
/*

    Defines the EvaluateBoolexpr and ExecuteCode functions. Used for executing callbacks without having
to add them to a trigger first.

*/

globals
    private force ENUM_FORCE = CreateForce()
endglobals

public function EvaluateBoolexpr takes boolexpr callback returns nothing
    call ForceEnumAllies(ENUM_FORCE, Player(PLAYER_NEUTRAL_AGGRESSIVE), callback)
endfunction

public function ExecuteCode takes code callback returns nothing
    call ForForce(bj_FORCE_PLAYER[0], callback)
endfunction


endlibrary