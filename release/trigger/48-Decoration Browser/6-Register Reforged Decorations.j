library RegisterReforgedDecorations requires RegisterDecorationNames

//! runtextmacro optional LoPUnitCompatibility()

private function StringHash takes string str returns integer
    return StringHashEx(str)
endfunction


globals
    private hashtable hashHandle = InitHashtable()
endglobals  
//! runtextmacro DeclareParentHashtableWrapperModule("hashHandle", "true", "GeneralHashtable", "private")
//! runtextmacro DeclareParentHashtableWrapperStruct("GeneralHashtable","private")

struct ReforgedDecorationList extends array
    //! runtextmacro HashStruct_SetHashtableWrapper("GeneralHashtable")
    
    //! runtextmacro HashStruct_NewPrimitiveFieldEx("GeneralHashtable", "size", "integer", "-1")
    //! runtextmacro HashStruct_NewStructFieldEx("GeneralHashtable", "sub", "thistype", "-2")
    //! runtextmacro HashStruct_NewStructFieldEx("GeneralHashtable", "sup", "thistype", "-3")

    implement DecorationListTemplate
endstruct
    
//! runtextmacro RegisterDecorationNamesFunctionTemplate("ReforgedDecorationList")


/*
Registering unit names on the decoration list takes quite a lot of processing, which means it can 
easily hit the OP limit imposed by JASS. To avoid this, we have to execute the code in separate threads.

This code is automatically generated using the searchindexernew.py script in the repository.
*/
private module A0
private static method onInit takes nothing returns nothing
call RegisterThing('h1XR')
call RegisterThing('h1X0')
call RegisterThing('h1WZ')
call RegisterThing('h1X3')
call RegisterThing('h1X2')
call RegisterThing('h1X1')
call RegisterThing('h1XS')
call RegisterThing('h1X4')
call RegisterThing('h1X5')
call RegisterThing('h1VV')
call RegisterThing('h1W0')
call RegisterThing('h1W3')
call RegisterThing('h1VW')
call RegisterThing('h1VY')
call RegisterThing('h1VU')
call RegisterThing('h1W1')
call RegisterThing('h1VX')
call RegisterThing('h1W2')
call RegisterThing('hshy')
call RegisterThing('h1VT')
call RegisterThing('h1VZ')
call RegisterThing('h1ZX')
call RegisterThing('h1ZU')
call RegisterThing('h1XT')
call RegisterThing('h1XU')
call RegisterThing('h1XW')
call RegisterThing('h1XZ')
call RegisterThing('h1XV')
call RegisterThing('h1XY')
call RegisterThing('h1XX')
call RegisterThing('h1Y0')
call RegisterThing('h1WR')
call RegisterThing('h1WW')
call RegisterThing('h1WT')
call RegisterThing('h1WU')
call RegisterThing('h1WY')
call RegisterThing('h1WX')
call RegisterThing('h1WV')
call RegisterThing('h1WS')
call RegisterThing('h1WQ')
call RegisterThing('eshy')
call RegisterThing('h1W5')
call RegisterThing('h1W6')
call RegisterThing('h1WA')
call RegisterThing('h1WB')
call RegisterThing('h1W4')
call RegisterThing('h1WE')
call RegisterThing('oshy')
call RegisterThing('h1W9')
call RegisterThing('h1W8')
call RegisterThing('h1WD')
call RegisterThing('h1W7')
call RegisterThing('h1WC')
call RegisterThing('h1P5')
call RegisterThing('h1P6')
call RegisterThing('h1P7')
call RegisterThing('h1P8')
call RegisterThing('h1P9')
call RegisterThing('h1PA')
call RegisterThing('h1PB')
call RegisterThing('h1PC')
call RegisterThing('h1PD')
call RegisterThing('h1PI')
call RegisterThing('h1PE')
call RegisterThing('h1PF')
call RegisterThing('h1PG')
call RegisterThing('h1PH')
call RegisterThing('h1RD')
call RegisterThing('h1R9')
call RegisterThing('h1QX')
call RegisterThing('h1RC')
call RegisterThing('h1R7')
call RegisterThing('h1RE')
call RegisterThing('h1R8')
call RegisterThing('h1R6')
call RegisterThing('h1QY')
call RegisterThing('h1RB')
call RegisterThing('h1R4')
call RegisterThing('h1QZ')
call RegisterThing('h1RA')
call RegisterThing('h1RG')
call RegisterThing('h1R2')
call RegisterThing('h1R3')
call RegisterThing('h1R0')
call RegisterThing('h1R1')
call RegisterThing('h1RI')
call RegisterThing('h1RH')
call RegisterThing('h1R5')
call RegisterThing('h1RF')
call RegisterThing('h1ZW')
call RegisterThing('h1ZT')
call RegisterThing('h1ZY')
call RegisterThing('h1ZV')
call RegisterThing('h1WH')
call RegisterThing('h1WN')
call RegisterThing('h1WI')
call RegisterThing('h1WK')
call RegisterThing('h1WO')
call RegisterThing('h1WF')
call RegisterThing('h1WJ')
call RegisterThing('ushp')
call RegisterThing('h1WL')
call RegisterThing('h1WM')
call RegisterThing('h1WP')
call RegisterThing('h1WG')
endmethod
endmodule
private struct Nice extends array
implement A0
endstruct

endlibrary