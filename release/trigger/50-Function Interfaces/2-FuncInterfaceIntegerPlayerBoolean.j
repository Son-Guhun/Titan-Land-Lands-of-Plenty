library FuncInterfaceIntegerPlayerBoolean requires FuncInterface

    //! textmacro FuncInterfaceIntegerPlayerBoolean_evaluate takes func, i, p, b
        call BJDebugMsg("before")
        set FuncInterface.stack.integer[0] = $i$
        set FuncInterface.stack.player[1] = $p$
        set FuncInterface.stack.boolean[2] = $b$
        
        call BJDebugMsg("mid")
        call FuncInterface.evaluateAltName($func$)
        call BJDebugMsg("after")
        call FuncInterface.stack.flush()
    //! endtextmacro

    public function evaluate takes boolexpr func, integer i, player p, boolean b returns nothing
        //! runtextmacro FuncInterfaceIntegerPlayerBoolean_evaluate("func", "i", "p", "b")
    endfunction

endlibrary