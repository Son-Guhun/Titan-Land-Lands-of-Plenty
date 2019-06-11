from myconfigparser import MyConfigParser, load_unit_data, get_decorations



import pyperclip

keys = ['modelScale','red','green','blue']

def do(file_path):
    with open(FILE_PATH) as f:
        unit_data = load_unit_data(f)

    result = []
    decos = get_decorations(unit_data)

    for deco in decos:
        for key in keys:
            if key in unit_data[deco]:
                result.append(" set UnitTypeDefaultValues('{}').{} = {}".format(deco,
                                                                                key,
                                                                                unit_data[deco][key]))

    pyperclip.copy('\n'.join(result))
