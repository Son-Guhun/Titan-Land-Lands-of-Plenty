"""
Credits to gohagga for the algorithm.
"""

from myconfigparser import UnitParser, Section, load_unit_data, get_decorations
import pyperclip



LIBRARY_DECLARATION = """
library LoPUnitCompatibility requires TableStruct

private keyword InitModule

// This is an optional textmacro that will replace GetObjectName when implemented
//! textmacro LoPUnitCompatibility
    private function GetObjectName takes integer objectCode returns string
        return LoPUnitType(objectCode).name
    endfunction
//! endtextmacro

struct LoPUnitType extends array
    static key table_impl

    //! runtextmacro TableStruct_NewPrimitiveField("name", "string")
    
    implement InitModule
endstruct

private module InitModule
    private static method onInit takes nothing returns nothing
{}
    endmethod
endmodule

endlibrary
"""

DATABASE = '../development/table/unit.ini'



def do(database):
    with open(database) as f:
        data = load_unit_data(f, parser=UnitParser)

    lines = []
    for unit in data:
        lines.append(f"set LoPUnitType('{unit}').name = {Section(data[unit])['Name']}\n")
    pyperclip.copy(LIBRARY_DECLARATION.format(''.join(lines)))

