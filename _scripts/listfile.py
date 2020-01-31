"""This script can be used to generate a listfile from the unit data in the map. Can be used in case of data loss.
"""
from myconfigparser import MyConfigParser, load_unit_data, get_decorations

file_path = '../development/table/unit.ini' # filepath to newer version
listfile = '../.future/(listfile).txt'  # listfile from an older version
target = '../.future/listfile.txt' # new listfile

def do_everything():
    with open(listfile) as f:
        lines = set(f.readlines())         
    with open(file_path) as f:
        unit_data = load_unit_data(f)

    for unit in unit_data:
        data = unit_data[unit]
        if 'file' in data:
            model = data['file'][1:-5].replace('\\\\', '\\')
            lines.add(model +'.mdx' + '\n')
            lines.add(data['file'][1:-5].replace('\\\\', '\\') + '_Portrait' +'.mdx' + '\n')

    with open(target, 'w') as f:
        f.writelines(sorted(lines))
    
