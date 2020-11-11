import json

def do():
    results = {}

    with open('derivatives.json') as f:
        results = json.load(f)

    with open('model2pathmap.json') as f:
        model2pathmap = json.load(f)

    with open('used_pathtexs.json') as f:
        used_pathtexs = set(json.load(f))

    for model in list(model2pathmap.keys()):
        if model2pathmap[model] not in used_pathtexs:
            del model2pathmap[model]

    for model in model2pathmap:
        if model not in results:
            results[model] = ""

    with open('derivatives.json', 'w') as f:
        json.dump(results, f, indent=2)
    
