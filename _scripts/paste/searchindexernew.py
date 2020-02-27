"""
Credits to gohagga for the algorithm.
"""

from myconfigparser import UnitParser, Section, load_unit_data, get_decorations
import pyperclip

def comparator(pair):
    return len(pair[0]), pair[0].lower(), pair[0]

DATABASE = '../development/table/unit.ini'


MAX = 300

def do(dataBase, reforged=False):
    with open(dataBase) as f:
        unit_data = load_unit_data(f, parser=UnitParser)

    cond = lambda x: x['campaign'] == ('1' if reforged else '0')
    comparator = lambda x: x['Name'].lower()
    decorations = sorted(filter(cond, unit_data.get_primary_decorations()), key=comparator)
    
    lines = []
    i = 0
    for decor in decorations:
        if i%MAX == 0:
            lines.append('endmethod\nendmodule' if i > 0 else '')
            lines.append(f'private module A{i}')
            lines.append(f'private static method onInit takes nothing returns nothing')
        lines.append(f"call RegisterThing('{decor.name}')")
        i += 1

    if lines[-1] != 'endmethod\nendmodule':
        lines.append('endmethod\nendmodule')
    lines.append('private struct Nice extends array')
    i = 0
    while i < len(decorations):
        lines.append(f'implement A{i}')
        i = i + MAX
    lines.append('endstruct')                
    pyperclip.copy('\n'.join(lines))

