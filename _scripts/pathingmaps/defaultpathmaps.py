import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import MyConfigParser, load_unit_data, get_decorations, Section
from collections import defaultdict
import json
import pyperclip

file_path = '../../development/table/unit.ini'


def do(file_path=file_path):
    result = ['//! textmacro GeneratedDecorationPathMaps']
    
    with open('model2pathmap.json') as f:
        model2pathmap = json.load(f)

    with open('used_pathtexs.json') as f:
        used_pathtexs = set(json.load(f))

    print(len(model2pathmap))

    for model in list(model2pathmap.keys()):
        if model2pathmap[model] not in used_pathtexs:
            del model2pathmap[model]

    print(len(model2pathmap))

    with open(file_path) as f:
        unit_data = load_unit_data(f)

    decorations = get_decorations(unit_data)

    for decoration in decorations:
        data = Section(unit_data[decoration])
        isbldg = bool(int(data['isbldg']))

        
        if isbldg:
            pass
        else:
            model = data['file'].replace("war3.w3mod:","")
            if model in model2pathmap:
                result.append(f'set thistype(\'{decoration}\').path = paths["{model2pathmap[model]}"]')
            else:
                for i in (-4,-5,-6):
                    modelN = model[:-1][:i] + '"'
                    if modelN in model2pathmap:
                        result.append(f'set thistype(\'{decoration}\').path = paths["{model2pathmap[modelN]}"]')
                        break


    result.append('//! endtextmacro')
    pyperclip.copy("\n".join(result))


            
