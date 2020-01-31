"""This script iterates over all decorations in a .ini database and set their Specialart field
to the format expected by the SpecialEffect system.
"""
from myconfigparser import MyConfigParser, load_unit_data, iter_deco_builders

path = '../development/table/unit.ini'
template = "set UpgradeData('{}').{} = '{}'"

class Decoration:
    def __init__(self, rawcode, upgrades, first):
        if len(upgrades) > 1:
            self.prev = upgrades[1]
        else:
            self.prev = None
        self.next = upgrades[0]
        self.first = first
        self.rawcode = rawcode

def do(file_path):
    with open(file_path) as f:
        unit_data = load_unit_data(f)

    result = []
    decos = []
    added = set()
    cond = lambda x: '[spawn]' not in unit_data[x]['EditorSuffix'] if 'EditorSuffix' in unit_data[x] else True
    for builder in iter_deco_builders(unit_data, builder_only=True):
        for decoration in builder['Builds'][1:-1].split(','):
            if decoration not in added and 'Upgrade' in unit_data[decoration] and unit_data[decoration]['Upgrade'] != '""' and cond(decoration):
                upgrades = unit_data[decoration]['Upgrade'][1:-1].split(',')
                decos.append(Decoration(decoration, upgrades, decoration))
                added.add(decoration)
                upgrade = upgrades[0]
                i = 0
                while upgrade != decoration:
                    if upgrade not in unit_data:
                        print('({}) Inexistant upgrade: '.format(decoration) + upgrade)
                        break
                    if i > 20 or 'Upgrade' not in unit_data[upgrade]:
                        print('Broken upgrade chain: {}'.format(decoration))
                        break
                    upgrades = unit_data[upgrade]['Upgrade'][1:-1].split(',')
                    decos.append(Decoration(upgrade, upgrades, decoration))
                    upgrade = upgrades[0]
                    added.add(upgrade)
                    i += 1

    series = None  # Assuming decorations will be listed in chunks, where the next chunk is the first decoration of another upgrade line
    for decoration in decos:
        if decoration.prev:
            result.append(template.format(decoration.rawcode, 'prev', decoration.prev))
        result.append(template.format(decoration.rawcode, 'next', decoration.next))
        result.append(template.format(decoration.rawcode, 'first', decoration.first))

        if decoration.first == decoration.rawcode:
            if series is not None and len(series) > 2:
                length = len(series)
                for i,d in enumerate(series):
                    unit_data[d]['Upgrade'] = '"{},{}"'.format(series[(i+1)%length], series[(i-1)%length])
            series = [decoration.rawcode]
        else:
            series.append(decoration.rawcode)

    with open(file_path, 'w') as f:
        unit_data.write(f)

    
    return '\n'.join(result)
    
