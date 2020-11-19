"""
This script fixes model paths in a database which are using don't use two backslashes as a separator.
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
    
