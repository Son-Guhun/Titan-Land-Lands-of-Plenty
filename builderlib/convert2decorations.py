"""This script converts each CUSTOM unit in a list to a decoration, using 'h038' as the base unit.

Does not function for default units, as the _parent object field is overriden.
"""
import os
from myconfigparser import MyConfigParser, load_unit_data, get_decorations

fields_to_keep = [
    'Name', 'EditorSuffix', 'Tip', 'Ubertip', 'Art', 'file'
    ]

units_list = 'h00J,h084,u05F,e010,e00Z,u018,e02D,o02E,h0HP,h06Q,h0NE,h06D,h00I,h11T,h06G,h0DX,h05W'
units_list = units_list.split(',')

def do(dataBase, units_list):
    with open(dataBase) as f:
        unit_data = load_unit_data(f)

    for rawcode in units_list:
        unit = unit_data[rawcode]

        values = {k:unit[k] if k in unit else None for k in fields_to_keep}
        
        unit_data[rawcode] = unit_data['h038']
        
        for k,v in values.items():
            if v is not None:
                unit[k] = v

    with open(dataBase, 'w') as f:
        unit_data.write(f)

