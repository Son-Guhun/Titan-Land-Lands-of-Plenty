import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import MyConfigParser, load_unit_data
from collections import defaultdict
import json

model_fields = ('file', '"file:hd"', '"file:sd"')

# Hardcoded duplicates that can't be automatically handled
hardcoded = {
    '"Doodads\\\\Silvermoon\\\\Structures\\\\SilvermoonWallStraightDoorShort\\\\SilvermoonWallStraightDoorShort_0.mdl"': "PathTextures\\\\22x8Default.tga"
    }

def do():
    results = defaultdict(lambda: set())

    def parse(parser):
        for s in parser:
            section = parser[s]
            if 'pathtex' in section and section['pathtex'] not in ('"none"', '""'):
                for field in model_fields:
                    results[section[field]].add(section['pathtex'])

        # Handle duplicates automatically
        for s in parser:
            section = parser[s]
            models = [section[field] for field in model_fields]
            if models.count(models[0]) == 3:
                model = models[0]
                if model in results:
                    if 'pathtex' in section and section['pathtex'] not in ('"none"', '""'):
                        results[model] = set([section['pathtex']])
                    else:
                        del results[model]
            


    
    with open('../doodad.ini') as f:
        parse(load_unit_data(f))

    with open('../unit_1.32.8.ini') as f:
        parse(load_unit_data(f))
        

    for model in hardcoded:
        results[model] = set([hardcoded[model]])

    duplicates = []
    for model in results:
        if len(results[model]) > 1:
            duplicates.append(model)

    if duplicates:
        for d in duplicates: print(d)
        raise ValueError("Duplicate pathtextures found")

    results = {x:next(iter(y)) for x,y in results.items()}
    results = {x:y[y.rfind('\\')+1:-1].lower() for x,y in results.items()}

    with open('model2pathmap.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    # return results

# a = do()
# 
