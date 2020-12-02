import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import UnitParser, load_unit_data, Decoration
import itertools

file_path = '../../development/table/unit.ini'

def do(file_path=file_path):

    with open(file_path) as f:
        data = load_unit_data(f, parser=UnitParser)

    fil = lambda u: u.get_version() == 2
    itr = itertools.chain(data.get_selectors(),
                          data.get_builders(),
                          data.get_decobuilders(),
                          filter(lambda u: u.name != 'udr0', data.get_decorations()),
                          data.get_heroes(),
                          data.get_production_bldgs(),
                          data.get_troops())
    
    for unit in filter(fil, itr):
        icon = unit['Art'][1:]

        if type(unit) == Decoration and  icon.startswith('war3.w3mod:'):
            icon = icon[len('war3.w3mod:'):]

        if icon.startswith('war3.w3mod:'):
            print(f'Error: classic unit {unit["Name"]} [{unit.name}] is considered Reforged.')

        elif not icon.startswith('_hd.w3mod:'):
            unit['Art'] = '"_hd.w3mod:' + icon

        # print(unit['Name'])

    
    with open(file_path, 'w') as f:
        data.write(f)
