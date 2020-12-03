import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from myconfigparser import UnitParser, load_unit_data, get_decorations, Section
from collections import defaultdict
import json
import pyperclip

file_path = '../../development/table/unit.ini'


def do(file_path=file_path):
    pass

with open('used_pathtexs.json') as f:
        used_pathtexs = set(json.load(f))

with open(file_path) as f:
    unit_data = load_unit_data(f, parser=UnitParser)

decorations = filter(lambda d: d.isbldg() and not d.has_tag('spawn'),
                     unit_data.get_decorations())

r = {}

for d in decorations:
    # print(f"{d['pathTex']} ({d['Name']} [{d.name}])")
    path = d['pathTex'].lower()[1:-1]

    if not path:
        r[d.name] = path
        continue
    elif path.startswith('pathtextures'):
        path = path[path.rfind('\\')+1:]
    else:
        path = path[path.rfind('\\')+1:]
        path = 'lop\\\\' + path

    r[d.name] = path
    if path in used_pathtexs:
        pass
    else:
        print(f"Missing: {path} ({d['Name']} [{d.name}])")

with open('legacy_structures.json', 'w') as f:
    json.dump(r, f, indent=4)


            
