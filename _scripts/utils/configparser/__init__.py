try:
    from s2id import Rawcode
except:
    from ...s2id import Rawcode
    
from configparser import ConfigParser

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

def load_unit_data(fp, parser=MyConfigParser):
    unit_data = parser(delimiters=("=",))
    unit_data.readfp(fp, 'unit.ini')
    return unit_data
