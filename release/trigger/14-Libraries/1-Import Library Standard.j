/*
    This file defines the standard for a Python-inspired importing syntax. Since it only offers textmacros
for implementation, an actual vJass library is not needed, and projects that use this standard don't need
to require anything explicitly.

======================================================================

STANDARD DEFINITION:
    A library is declared as a struct that extends array. The library should not be used as a struct
that can be instanciated, so methods like create and destroy should not be defined.

        - Functions are static methods, and use CamelCase (to match normal functions in jass).
        - Constants use CAPITAL_LETTERS.
        - Globals use cameCase.
        
    Libraries can import other library by running the "ImportLibAs(LIB, ALIAS)" textmacros. Example:
    
        struct LibA extends array
            //! runtextmacro ImportLibAs("LibB", "B")
        endstruct
    
    Now function Func in library be can be accessed using:
    
        LibA.B.Func()
    
    Globals and Consants can also be imported using the following textmacros. Assume that both the
constant CONST of type integer and the global myUnit of type unit exist in LibB:
    
        struct LibA extends array
            //! runtextmacro FromLibImportConstant("LibB", "CONST", "integer")
            //! runtextmacro FromLibImportGlobal("LibB", "myUnit", "unit")
        endstruct
        
    Now these variables can be accesed using:
    
        LibA.CONST
        LibA.myUnit
        
    Library names should use CamelCase. Imported libraries should also use CamelCase, unless the imported
library was privately declared and is only accessible as a member. Then it should use camelCase.

        private sturct LibC extends array
        endstruct
        
        struct LibA extends array
            //! runtextmacro ImportLibAs("LibB", "LibraryBee")
            //! runtextmacro ImportLibAs("LibC", "libraryCee")
        endstruct
    
    
======================================================================
    
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
