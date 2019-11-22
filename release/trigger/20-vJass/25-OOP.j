// Contains tools of Object-Oriented Programming
library OOP

//! textmacro InheritField takes STRUCT, FIELD, TYPE
    method operator $FIELD$ takes nothing returns $TYPE$
        return $STRUCT$(this).$FIELD$
    endmethod
    
    method operator $FIELD$= takes $TYPE$ value returns nothing
        set $STRUCT$(this).$FIELD$ = value
    endmethod
//! endtextmacro

//! textmacro InheritFieldReadonly takes STRUCT, FIELD, TYPE
    method operator $FIELD$ takes nothing returns $TYPE$
        return $STRUCT$(this).$FIELD$
    endmethod
//! endtextmacro

// Not really for OOP but who cares
//! textmacro BeginInitializer takes NAME
    private keyword $NAME$_M
    
    private struct $NAME$_S extends array
        implement $NAME$_M
    endstruct
    
    private module $NAME$_M
        private static method onInit takes nothing returns nothing
//! endtextmacro
//! textmacro EndInitializer
        endmethod
    endmodule
//! endtextmacro
        
endlibrary