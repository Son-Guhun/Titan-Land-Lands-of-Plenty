/*
    This file defines the standard for a Python-inspired importing syntax. Since it only offers textmacros
for implementation, an actual vJass library is not needed, and projects that use this standard don't need
to require anything explicitly.
    
    The following textmacros can be used to implement this standard:
*/
//! textmacro ImportLibAs takes LIB, ALIAS
    static method operator $ALIAS$ takes nothing returns $LIB$
        return 0
    endmethod
//! endtextmacro

//! textmacro FromLibImportConstant takes LIB, CONSTANT, TYPE
     static method operator $CONSTANT$ takes nothing returns $TYPE$
        return $LIB$.$CONSTANT$
    endmethod   
//! endtextmacro

//! textmacro FromLibImportGlobal takes LIB, GLOBAL, TYPE
     static method operator $GLOBAL$ takes nothing returns $TYPE$
        return $LIB$.$GLOBAL$
    endmethod   
//! endtextmacro
