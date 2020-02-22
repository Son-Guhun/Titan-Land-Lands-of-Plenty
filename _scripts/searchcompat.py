"""
Credits to gohagga for the algorithm.
"""

from myconfigparser import UnitParser, Section, load_unit_data, get_decorations
import pyperclip



LIBRARY_DECLARATION = """
library LoPUnitCompatibility requires ConstTable

private key InitModule

// This is an optional textmacro that will replace GetObjectName when implemented
//! textmacro LoPUnitCompatibility takes nothing returns nothing
    function GetObjectName takes integer objectCode returns nothing
        return LoPUnitCompatibility.name.string[objectCode]
    endfunction
//! endtextmacro

struct LoPUnitCompatibility extends array
    static key table_impl

    method operator name takes nothing returns ConstTable
        return table_impl
    endmethod

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
        lines.append(f"""set name.string['{unit}'] = "{Section(data[unit])['Name']}"\n""")
    pyperclip.copy(LIBRARY_DECLARATION.format(''.join(lines)))

