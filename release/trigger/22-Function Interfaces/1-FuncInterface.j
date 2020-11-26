/*

This library aims to be an alternative to the vJass function interfaces


To define prototypes, one must create libraries in the following pattern:

library FuncInterfaceType1Type2Type3ReturnType4

    //! textmacro FuncInterfaceType1Type2Type3ReturnType4__evaluate takes ret, func, t1, t2, t3, t4
    
    public function evaluate takes code func, type1 t1, type2 t2, type3 t3, type4 t4

endlibrary
*/
library FuncInterface requires Table

    struct FuncInterface extends array
        private static key tab
        private static trigger trig = CreateTrigger()
        
        static method operator stack takes nothing returns Table  // use Table instead of ConstTable because it has .handle.setValue().
            return tab
        endmethod
        
        static method evaluate takes boolexpr func returns nothing
            local triggercondition cond = TriggerAddCondition(trig, func)
            call TriggerEvaluate(trig)
            call TriggerRemoveCondition(trig, cond)
        endmethod
        
        static method evaluateAltName takes boolexpr func returns nothing
            call .evaluate(func)
        endmethod
        
    endstruct
    
    //! textmacro FuncInterface_Return takes type, val
        set FuncInterface.stack.$type$[-1] = $val$
    //! endtextmacro
endlibrary
//! novjass
////////////////////////////////////////////////////////////////////
/* Below is an example library where the function prototype has a return values */
library FuncInterfaceUnitRectReturnsBoolean requires FuncInterface

    //! textmacro FuncInterfaceUnitRectReturnsBoolean_evaluate takes ret, func, u, r
        set FuncInterface.stack.unit[0] = $u$
        set FuncInterface.stack.rect[1] = $r$
        
        call FuncInterface.evaluateAltName($func$)
        set $ret$ = FuncInterface.stack.boolean[-1]
        call FuncInterface.stack.flush()
    //! endtextmacro

    public function evaluate takes boolexpr func, unit u, rect r returns boolean
        local boolean ret
        //! runtextmacro FuncInterfaceUnitRectReturnsBoolean_evaluate("ret", "func", "u", "r")
        return ret
    endfunction

endlibrary
/////////////////////////////////////
// We define the argument header textmacro in each library, because if the library changes which protype it uses,
// error messages will be thrown for any functions that were using that library, instead of silent errors occuring.
//! textmacro OnEnterArguments takes unit, rect
    local unit $unit$ = FuncInterface.stack.unit[0]
    local rect $rect$ = FuncInterface.stack.rect[1]
//! endtextmacro

// Same logic applies to the return value, which can be a function because of JassHelper inlining.
function OnEnterReturn takes boolean value returns nothing
    //! runtextmacro FuncInterface_Return("boolean", "value")
endfunction

///////////////////////////////
// Finally, here we have an example of a function that uses the prototypes defined above.
function OnEnterExample takes nothing returns nothing
    //! runtextmacro OnEnterArguments("whichUnit", "whichRect")
    
    call BJDebugMsg(GetUnitName(whichUnit))
    
    call OnEnterReturn(GetRectWidthBJ(whichRect) > 500.)
endfunction
//! endnovjass