import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import UnitParser, load_unit_data, Decoration

file_path = '../../development/table/unit.ini'

def do(file_path=file_path):

    with open(file_path) as f:
        data = load_unit_data(f, parser=UnitParser)

    fil = lambda d: d.isbldg() and d.allow_unselectable()
    
    for decoration in filter(fil, data.get_decorations()):
        name = decoration['Name'][1:]
        
        decoration['Name'] = '"_BLDG ' + name
        decoration['isbldg'] = '0'
        decoration['special'] = '1'
        print(decoration['Name'])
        print(decoration['special'])

    for decoration in filter(fil, data.get_decorations()):
        break
    else:
        print("Success! Empty.")

    
    with open(file_path, 'w') as f:
        data.write(f)
