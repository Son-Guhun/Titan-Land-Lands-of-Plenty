"""Gets properties from all decorations a .ini database and generates code to be used in the
UnitTypeDefaultValues library. This code is copied to the clipboard and can be pasted in a text
editor or inside the World Editor.
"""
import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))
#______________________________________________________________________________________________

from myconfigparser import MyConfigParser, load_unit_data, get_decorations
import pyperclip


keys = ['modelScale','red','green','blue','animProps','maxRoll']

def do(file_path='../../development/table/unit.ini'):
    with open(file_path) as f:
        unit_data = load_unit_data(f)

    result = []
    decos = get_decorations(unit_data)

    for deco in decos:
        for key in keys:
            if key in unit_data[deco]:
                if key == 'animProps':
                    result.append(" set UnitTypeDefaultValues('{}').{} = {}".format(deco,
                                                                                    key,
                                                                                    unit_data[deco][key].replace(',', ' ')))
                elif key != 'maxRoll' or float(unit_data[deco]['maxRoll']) < 0:
                    result.append(" set UnitTypeDefaultValues('{}').{} = {}".format(deco,
                                                                                    key,
                                                                                    unit_data[deco][key]))

    pyperclip.copy('\n'.join(result))
