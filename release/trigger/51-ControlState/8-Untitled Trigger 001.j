library CallbackTools

globals
    private force ENUM_FORCE = CreateForce()
endglobals

public function EvaluateBoolexpr takes boolexpr callback returns nothing
    call ForceEnumPlayersCounted(ENUM_FORCE, callback, 1)
endfunction



endlibrary