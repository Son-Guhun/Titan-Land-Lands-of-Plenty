"""This script iterates over all decorations in a .ini database and set their Specialart field
to the format expected by the SpecialEffect system.
"""
from myconfigparser import MyConfigParser, load_unit_data, get_decorations, Section

dataBase = '../development/table/unit.ini'

def configure_decorations(unit_data, decoration_list):
    for decoration in decoration_list:
        data = Section(unit_data[decoration])
        if data['_parent'] != decoration:
            if data['campaign'] == '1' and data['isbldg'] == '0' and data['hostilePal'] == '0':
                data['special'] = '1'
                data['campaign'] = '0'

def do(file_path):
    f = open(file_path)
    unit_data = load_unit_data(f)
    
    decorations = get_decorations(unit_data)
    configure_decorations(unit_data, decorations)
    
    f = open(file_path, 'w')
    unit_data.write(f)
    
