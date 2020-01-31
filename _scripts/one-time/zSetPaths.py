"""
This script adds the prefix 'war3.w3mod:' to the model and icon path for all units
which do not use a custom model. This was used to force SD models for old units
even in HD mode.
"""
import os

rootdir = '../release/resource'
all_files = set()

for subdir, dirs, files in os.walk(rootdir):
    res = 'resource'
    subdir = subdir[subdir.find(res)+len(res):]
    if subdir != '':
        subdir = subdir[1:] + os.sep

    for file in files:
        filepath = subdir + file

        all_files.add(filepath.lower())

from myconfigparser import MyConfigParser, load_unit_data, Section
import s2id

dataBase = "..\\development\\table\\unit.ini"

# print('{}: {}'.format(rawcode, unit_data[rawcode]['Name']))

def do(dataBase, upgrade_lists):
    
    with open(dataBase) as f:
        data = load_unit_data(f)

    for unit in (Section(data[u]) for u in data):
        model = unit['file'].replace('\\\\', '\\')[1:-1]
        icon = unit['Art'].replace('\\\\', '\\')[1:-1]

        if model.endswith('.mdl'):
            model = model[:model.rfind('.')] + '.mdx'
        
        try:
            if model.lower() not in all_files:
                # print('[{}]'.format(unit._section.name), unit['Name'])
                unit._section['file'] = '"{}"'.format('war3.w3mod:'+model).replace('\\','\\\\')
            if icon.lower() not in all_files:
                unit._section['Art'] = '"{}"'.format('war3.w3mod:'+icon).replace('\\','\\\\')
                # print(icon)
        except Exception as e:
            print(unit._section.name)
            raise e

    with open(dataBase, 'w') as f:
        data.write(f)

