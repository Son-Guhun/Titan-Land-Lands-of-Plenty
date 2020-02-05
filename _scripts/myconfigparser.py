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
    def __iter__(self):
        for section in super().__iter__():
            if section != 'DEFAULT':
                yield section

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

def iter_deco_builders(unit_data, builder_only = False, ability = 'A00J'):
    for unit in unit_data:
        unit = unit_data[unit]
        if 'abilList' in unit and ability in unit['abilList']:
            if not (builder_only and ('Builds' not in unit or unit['Builds'] == '""')):
                yield unit

defaults_path = 'unit.ini'
with open(defaults_path) as f:
    defaults = load_unit_data(f)

fields = set(('EditorSuffix', 'Hotkey', 'Builds', 'Trains', 'Upgrade', 'abilList'))

class Section:
    
    def __init__(self, section):
        if '_parent' not in section: print(section.name)
        self._section = section
        self._default = defaults[section['_parent'][1:-1]]
        self.name = section.name
        
    def __getitem__(self, i):
        if i in self._section:
                return self._section[i]
        try:
            return self._default[i.lower()]
        except KeyError:
            if i in fields:
                return '""'
            else:
                raise KeyError("Unknown field:", i)
    
    def __setitem__(self, i, value):
        in_defaults = i.lower() in self._default
        if in_defaults and self._default[i.lower()] == value and i in self._section:
            del self._section[i]
        else:
            if value == '""' and not in_defaults:
                if i in self._section:
                    del self._section[i]
            else:
                self._section[i] = value
        
    def __contains__(self, i):
         return i in self._section
        
    def __delitem__(self, i):
        del self._section[i]
