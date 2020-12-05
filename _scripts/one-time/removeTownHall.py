import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import UnitParser, load_unit_data, Decoration

file_path = '../../development/table/unit.ini'

def do(file_path=file_path):

    with open(file_path) as f:
        data = load_unit_data(f, parser=UnitParser)

    for unit in data.sections():
        classifications = unit.list('type')
        if 'townhall' in classifications:
            classifications.remove('townhall')
            unit['type'] = f'"{",".join(classifications)}"'
            print(unit['Name'])

    fil = lambda u: 'townhall' in u.list('type')

    for unit in filter(fil, data.sections()):
        print(unit['Name'])
        break
    else:
        print("Success! Empty.")

    
    with open(file_path, 'w') as f:
        data.write(f)
