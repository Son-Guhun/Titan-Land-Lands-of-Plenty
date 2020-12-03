import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import MyConfigParser, load_unit_data, get_decorations, Section
from collections import defaultdict
import json
import pyperclip

file_path = '../../development/table/unit.ini'

line_template = 'set thistype(\'{}\').path = paths["{}"]'
line_template_generic = 'set thistype(\'{}\').path = PathingMap.getGeneric({},{})'

def do(file_path=file_path):    
    with open('model2pathmap.json') as f:
        model2pathmap = json.load(f)

    with open('used_pathtexs.json') as f:
        used_pathtexs = set(json.load(f))

    with open('legacy_structures.json') as f:
        legacy = json.load(f)

    with open('derivatives.json') as f:
        derivatives = json.load(f)

    with open('customized_pathmaps.json') as f:
        customized = json.load(f)

    with open('excluded_decorations.txt') as f:
        excluded = set(line for line in (line.strip() for line in f) if not line.startswith('//') and line)
        

    print(len(model2pathmap))

    rawcodes = {}
    for model,codes in derivatives.items():
        for rawcode in codes.split(','):
            rawcodes[rawcode] = model 

    print(len(model2pathmap))

    with open(file_path) as f:
        unit_data = load_unit_data(f)

    decorations = get_decorations(unit_data)
    result = ['//! textmacro GeneratedDecorationPathMaps']
    missing = []

    for decoration in decorations:
        data = Section(unit_data[decoration])
        
        if decoration in legacy:
            if legacy[decoration]:
                result.append(line_template.format(decoration, legacy[decoration]))
            
        elif decoration in customized:
            result.append(line_template_generic.format(decoration, *customized[decoration]))
            
        else:
            if decoration in rawcodes:
                model = rawcodes[decoration]
            else:
                model = data['file'].replace("war3.w3mod:","")
                                 
            if model in model2pathmap:
                if model2pathmap[model] in used_pathtexs:
                    result.append(line_template.format(decoration, model2pathmap[model]))
                else:
                    if model2pathmap[model]:
                        print(data['Name'], model2pathmap[model])
            else:
                for i in (-1, -2, -4, -5, -6):  # exclude .mdl, then exlcude derivate number
                    modelN = model[:-1][:i] + '"'
                    
                    if modelN in model2pathmap:
                        if model2pathmap[modelN] in used_pathtexs:
                            result.append(line_template.format(decoration, model2pathmap[modelN]))
                        else:
                            if model2pathmap[modelN]:
                                print(data['Name'], model2pathmap[modelN])
                        break
                else:
                    if decoration not in excluded:
                        missing.append(data)


    result.append('//! endtextmacro')
    pyperclip.copy("\n".join(result))
    print(len(missing))
    for d in missing:
        print(f"Missing: {d['Name']} [{d.name}]")
    print(len(get_decorations(unit_data)))
