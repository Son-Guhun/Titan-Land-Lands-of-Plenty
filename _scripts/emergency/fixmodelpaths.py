"""This script iterates over all decorations in a .ini database and set their Specialart field
to the format expected by the SpecialEffect system.
"""
from myconfigparser import UnitParser, load_unit_data, Section

dataBase = '../development/table/unit.ini'

def do(file_path):
    with open(file_path) as f:
        unit_data = load_unit_data(f, parser=UnitParser)
    
    for unit in unit_data.sections():
        unit['file'] = unit['file'].replace('\\', '\\\\').replace('\\\\\\\\', '\\\\')
    
    with open(file_path, 'w') as f:
        unit_data.write(f)
    
