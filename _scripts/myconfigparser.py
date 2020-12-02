try:
    from utils.configparser import MyConfigParser, load_unit_data, units
except ImportError:
    from .utils.configparser import MyConfigParser, load_unit_data, units



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

import inspect
import os

module_path = os.path.abspath(inspect.getfile(inspect.currentframe()))
defaults_path = os.path.join(module_path, '../unit.ini')
with open(defaults_path) as f:
    units.DEFAULTS = load_unit_data(f)


Section = units.Section
Production = units.Production
Decoration = units.Decoration
UnitParser = units.UnitParser
