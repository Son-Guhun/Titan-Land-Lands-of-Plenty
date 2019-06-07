from configparser import ConfigParser

class MyConfigParser(ConfigParser):
    """A ConfigParser with a default interpolation of None and an optionxform method that returns the string itself."""

    def __init__(self, *args, **kwargs):
        if 'interpolation' not in kwargs: kwargs['interpolation'] = None
        
        super().__init__(*args, **kwargs)

    @staticmethod
    def optionxform(x):
        return x


def load_unit_data(fp):
    unit_data = MyConfigParser(strict=False,comment_prefixes='--')
    unit_data.readfp(fp, 'unit.ini')
    return unit_data

def get_decorations(unit_data, deco_ability = 'A0C6'):
    result = []
    for unit in unit_data:
        if 'abilList' in unit_data[unit] and deco_ability in unit_data[unit]['abilList']:
            result.append(unit)
    return result

def configure_decorations(unit_data, decoration_list):
    for decoration in decoration_list:
        try:
            unit_data[decoration]['Specialart'] = '"{}"'.format(',' + unit_data[decoration]['file'][1:-1])
        except:
            print("Could not find model data for {}.".format(decoration))

def do_everything(file_path):
    f = open(file_path)
    unit_data = load_unit_data(f)
    
    decorations = get_decorations(unit_data)
    configure_decorations(unit_data, decorations)
    
    f = open(file_path, 'w')
    unit_data.write(f)
    
