import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import MyConfigParser, load_unit_data, get_decorations, Section
from collections import defaultdict
import json
import pyperclip

file_path = '../../development/table/unit.ini'

line_template = 'set thistype(\'{}\').path = paths["{}"]'

def do(file_path=file_path):
    result = ['//! textmacro GeneratedDecorationPathMaps']
    missing = []
    
    with open('model2pathmap.json') as f:
        model2pathmap = json.load(f)

    with open('used_pathtexs.json') as f:
        used_pathtexs = set(json.load(f))

    with open('legacy_structures.json') as f:
        legacy = json.load(f)

    with open('derivatives.json') as f:
        derivatives = json.load(f)

    print(len(model2pathmap))

    # Delete pathing maps that haven't been converted.
    for model in list(model2pathmap.keys()):
        if model2pathmap[model] not in used_pathtexs:
            del model2pathmap[model]

    rawcodes = {}
    for model,codes in derivatives.items():
        for rawcode in codes.split(','):
            rawcodes[rawcode] = model 

    print(len(model2pathmap))

    with open(file_path) as f:
        unit_data = load_unit_data(f)

    decorations = get_decorations(unit_data)

    for decoration in decorations:
        data = Section(unit_data[decoration])
        
        if decoration in legacy:
            result.append(line_template.format(decoration, legacy[decoration]))
        else:
            if decoration in rawcodes:
                model = rawcodes[decoration]
            else:
                model = data['file'].replace("war3.w3mod:","")
                                 
            if model in model2pathmap:
                result.append(line_template.format(decoration, model2pathmap[model]))
            else:
                for i in (-1, -2, -4, -5, -6):  # exclude .mdl, then exlcude derivate number
                    modelN = model[:-1][:i] + '"'
                    
                    if modelN in model2pathmap:
                        result.append(line_template.format(decoration, model2pathmap[modelN]))
                        break
                else:
                        missing.append(data)


    result.append('//! endtextmacro')
    pyperclip.copy("\n".join(result))
    print(len(missing))
    for d in missing:
        print(f"Missing: {d['Name']} [{d.name}]")


def b():
    for x in a.split('\n'):
        x = x.strip()
        if not x.startswith('//') and x:
            yield x

c = set(b())
