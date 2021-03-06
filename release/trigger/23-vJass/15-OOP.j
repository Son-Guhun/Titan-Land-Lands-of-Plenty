// Contains tools of Object-Oriented Programming
library OOP

//! textmacro OOP_ConstantStructField takes type, name, value
    static constant method operator $name$ takes nothing returns $type$
        return $value$
    endmethod
//! endtextmacro

//! textmacro OOP_HandleStruct takes type
    static method get takes $type$ h returns thistype
        return GetHandleId(h)
    endmethod
    
    static method operator [] takes $type$ h returns thistype
        return thistype.get(h)
    endmethod
//! endtextmacro

public module CatchNullPointerEx
    if this == 0 then
        call BJDebugMsg("Null pointer exception: $CURRENT_FUNCTION$")
    endif
endmodule

public module CatchNullPointer
    if this <= 0 then
        call BJDebugMsg("Invalid pointer (" + I2S(this) + ") exception: $CURRENT_FUNCTION$")
    endif
endmodule


public module PlayerStruct
    static method get takes player whichPlayer returns thistype
        return GetPlayerId(whichPlayer)
    endmethod
    
    static method operator[] takes player whichPlayer returns thistype
        return GetPlayerId(whichPlayer)
    endmethod
    
    method operator handle takes nothing returns player
        return Player(this)
    endmethod
endmodule

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

// Not really for OOP but who cares
//! textmacro Begin0SecondInitializer takes NAME
    private keyword $NAME$_M
    
    private struct $NAME$_S extends array
        implement $NAME$_M
    endstruct
    
    private module $NAME$_M
        private static method onStart takes nothing returns nothing
//! endtextmacro
//! textmacro End0SecondInitializer
            call DestroyTimer(GetExpiredTimer())
        endmethod

        private static method onInit takes nothing returns nothing
            call TimerStart(CreateTimer(), 0., false, function thistype.onStart)
        endmethod
    endmodule
//! endtextmacro
        
        
endlibrary