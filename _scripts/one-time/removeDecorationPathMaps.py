import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import UnitParser, load_unit_data, Decoration

file_path = '../../development/table/unit.ini'

def do(file_path=file_path):

    with open(file_path) as f:
        data = load_unit_data(f, parser=UnitParser)

    fil = lambda d: not d.isbldg()
    
    for decoration in filter(fil, data.get_decorations()):
        pathTex = decoration['pathTex'][1:-1]

        if 'preventPlace' in pathTex:
            decoration['pathTex'] = '""'
            decoration['preventPlace'] = '"_"'
            print("Fix preventPlace: ", decoration['Name'])
            
        elif pathTex and pathTex != 'none':
            decoration['pathTex'] = '""'
            print("Fix pathtex: ", decoration['Name'])

        if decoration['collision'] != '0.0':
            decoration['collision'] = '0.0'
            print("Fix collision: ", decoration['Name'])


    with open(file_path, 'w') as f:
        data.write(f)
