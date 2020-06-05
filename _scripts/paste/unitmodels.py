from myconfigparser import MyConfigParser, load_unit_data, get_decorations, Section
import pyperclip

file_path = '../development/table/unit.ini'

def get_models(unit_data):
    result = []
    for u in unit_data:
        unit = Section(unit_data[u])
        file = unit['file'][1:-1]
        try:
            file = unit['file'][1:-1]
            if file[-4] != '.':
                file = file + '.mdx'
            result.append(f"set d.string['{u}']=\"{file}\"")
        except:
            print("Could not find model data for {}.".format(u))
    return '\n'.join(result)

def do(file_path):
    f = open(file_path)
    unit_data = load_unit_data(f)
    
    pyperclip.copy(get_models(unit_data))
    
    
