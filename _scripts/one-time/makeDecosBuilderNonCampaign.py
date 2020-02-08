"""This script iterates over all decorations in a .ini database and set their Specialart field
to the format expected by the SpecialEffect system.
"""
from myconfigparser import UnitParser, load_unit_data, Section

dataBase = '../development/table/unit.ini'

def configure_decorations(unit_data, decoration_list):
    for decoration in decoration_list:
        data = Section(unit_data[decoration])
        if data['_parent'] != decoration:
            if data['campaign'] == '1' and data['isbldg'] == '0' and data['hostilePal'] == '0':
                data['special'] = '1'
                data['campaign'] = '0'

def do(file_path):
    with open(file_path) as f:
        unit_data = load_unit_data(f, parser=UnitParser)
    
    for deco in unit_data.get_decobuilders():
        deco['campaign'] = '0'
    
    with open(file_path, 'w') as f:
        unit_data.write(f)
    
