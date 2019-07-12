from myconfigparser import MyConfigParser, load_unit_data, get_decorations


def get_unit_abils(data):
    for ability in data:
        if ability == 'DEFAULT':
            continue
        try:
            if data[ability]['hero'] == '0' and data[ability]['item'] == '0':
                yield ability
        except KeyError as e:
            print(e)
            print(ability)



def do_everything(file_path):
    with open(file_path) as f:
        data = load_unit_data(f)

    result = []
    template = "call .registerAbility('{}', false)  //{}"
    for ability in get_unit_abils(data):
        if 'name' in data[ability]:
            result.append(template.format(ability, data[ability]['name']))
    
    return '\n'.join(result)
    
