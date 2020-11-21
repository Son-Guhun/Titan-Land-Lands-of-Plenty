// This function is used to easily print debug messages only if a certain condition is met.
// Boolean parameter is on front because the message might be big.
// I know this clashes with the function's name, but it should be better this way.
// Example usage:
//debug call Debug_PrintIf(IsUnitDeadBJ(whichUnit), GetUnitName(whichUnit)+ " is DEAD!"
library LoPDebug
function Debug_PrintIf takes boolean condition, string message returns nothing
    if condition then
        call BJDebugMsg(message)
    endif
endfunction

function ASSERT_impl takes boolean assertion, string funcName, string message returns nothing
    if not assertion then
        call BJDebugMsg("Assertion error (" + funcName + "): " + message)
    endif
endfunction

/*
function ASSERT takes boolean assertion, string message returns nothing
    call ASSERT_impl(assertion, SCOPE_PREFIX + "$FUNC_NAME", message)
endfunction

function ASSERT_NOTNULL takes handle h, string varName returns nothing
    call ASSERT(h != null, "Null pointer: " + varName)
endfunction

function ASSERT_NOTZERO takes integer num, string varName returns nothing
    call ASSERT(num != 0, "Null pointer: " + varName)
endfunction
*/

//! textmacro ASSERT takes assertion
    debug call ASSERT_impl($assertion$, SCOPE_PREFIX+"$FUNC_NAME", "$assertion$")
//! endtextmacro

module DebugNegativeIsNull
    debug static constant boolean REDEFINE_NULL = true
    debug method isNotNull takes nothing returns boolean
        debug return integer(this) >= 0
    debug endmethod
endmodule

module DebugPlayerStruct
    debug static constant boolean REDEFINE_NULL = true
    debug method isNotNull takes nothing returns boolean
        debug return integer(this) >= 0 and integer(this) < bj_MAX_PLAYERS
    debug endmethod
endmodule

module assertNotNull
    static if thistype.REDEFINE_NULL then
        debug call ASSERT_impl(this.isNotNull(), I2S(thistype.typeid), "Null object!")
    else
        debug call ASSERT_impl(this != null, I2S(thistype.typeid), "Null object!")
    endif
endmodule

endlibrary
