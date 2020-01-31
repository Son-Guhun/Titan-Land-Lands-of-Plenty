from myconfigparser import MyConfigParser, load_unit_data, Section

dataBase = "..\\development\\table\\unit.ini"


def do(file_path):
    with open(file_path) as f:
        data = load_unit_data(f)
    
    for unit in (Section(data[u]) for u in data):
        if 'modelScale' not in unit and 'A0C6' not in unit['abilList']:
            unit['modelScale'] = str(float(unit['modelScale']) + 0.01)
            unit['EditorSuffix'] = '"{}"'.format(unit['EditorSuffix'][1:-1] + '[tempSize]')
    
    with open(file_path, 'w') as f:
       data.write(f)

def undo(file_path):
    # To be implemented
    pass
    
