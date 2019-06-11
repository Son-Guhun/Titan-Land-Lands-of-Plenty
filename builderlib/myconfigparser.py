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
