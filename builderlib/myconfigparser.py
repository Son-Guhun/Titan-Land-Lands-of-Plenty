from configparser import ConfigParser
from s2id import Rawcode

class MyConfigParser(ConfigParser):
    """A ConfigParser with different default constructor arguments and an optionxform method that returns the string itself.

    Accepts any keyword argument that is also present in ConfigParser's constructor.    
    """

    def __init__(self, interpolation=None, strict=False, comment_prefixes='--', **kwargs):
        
        super().__init__(interpolation=interpolation,
                         strict=strict,
                         comment_prefixes=comment_prefixes,
                         **kwargs)

    @staticmethod
    def optionxform(x):
        return x

    def new_rawcode(self, initial='1000'):
        """Returns a string containing an unused rawcode (in upper case)."""
        initial = Rawcode(initial.upper())
        used_rawcodes = set(rawcode.upper() for rawcode in self)
        while initial in used_rawcodes:
            initial += 1
        return str(initial)
    

def load_unit_data(fp):
    unit_data = MyConfigParser()
    unit_data.readfp(fp, 'unit.ini')
    return unit_data

def get_decorations(unit_data, deco_ability = 'A0C6'):
    result = []
    for unit in unit_data:
        if 'abilList' in unit_data[unit] and deco_ability in unit_data[unit]['abilList']:
            result.append(unit)
    return result


