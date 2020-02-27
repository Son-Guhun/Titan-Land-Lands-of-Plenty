"""This script iterates over all production buildings (see tags) in a .ini database and assigns hotkeys to all units produced by those buildings.

Hotkey order: [Q,W,E,R,A,S,D,F,Z,W,C,V]
Production buildings: sets hotkeys for trained units in the order that they appear.
Race Selectors: configures hotkeys for upgrades, then for trained units, in the order that each appears.

"""

from myconfigparser import Section, load_unit_data, get_decorations, iter_deco_builders
import traceback
import itertools

HOTKEYS = ['"Q"','"W"','"E"','"R"',
           '"A"','"S"','"D"','"F"',
           '"Z"','"X"','"C"','"V"']

def set_hotkeys(unit_data, unit_list, structure, **kwargs):
    for i,u in enumerate(unit_list):
        #if i > 6:
        #    i += 1  # Skip rally point ability
        try:
            unit = Section(unit_data[u])
            unit['Buttonpos_2'] = str(i//4)
            unit['Buttonpos_1'] = str(i%4)
            unit['Hotkey'] = HOTKEYS[i]
            for key in kwargs:
                try:
                    value = kwargs[key]
                    if callable(value):
                        unit[key] = value(unit)
                    else:
                        unit[key] = value
                except:
                    print('Error in {} for {}.'.format(key, unit.name))
                    # traceback.print_exc()
        except KeyError as e:
            print(f'Could not find data for trained unit [{u}] in [{structure}]')

MAX_UPGRADES = 10  # Maximum number of upgrades that a single production building can have.
def configure_trained_units(unit_data, building_list, **kwargs):
    for building in building_list:
        try:
            series = [building]
            data = unit_data[building]
            if 'Upgrade' in data and data['Upgrade'] != '""':
                upgrade = data['Upgrade'][1:-1]
                while upgrade != building:
                    series.append(upgrade)
                    if 'Upgrade' not in unit_data[upgrade]:
                        raise ValueError(f'In chain [{building}], upgrade [{upgrade}] has no upgrades')
                    upgrade = unit_data[upgrade]['Upgrade'][1:-1]
                    if len(series) > MAX_UPGRADES:
                        raise ValueError('Could not find original building ({}) in upgrade depth of {}.'.format(building, MAX_UPGRADES))
            
            for structure in series:
                try:
                    if unit_data[structure]['Trains'] == '""':
                         raise ValueError()
                    trained_list = unit_data[structure]['Trains'][1:-1].split(',')
                    set_hotkeys(unit_data, trained_list, structure, **kwargs)
                except (KeyError, ValueError):
                    print('Could not find any units trained by: ' + structure)
        except Exception as e:
            print('Exception in building: ' + building)
            traceback.print_exc()

def configure_selectors(unit_data, selector_list, **kwargs):
    for selector in selector_list:
        count = 0
        if unit_data[selector]['Upgrade'] != '""':
            upgrade_list = unit_data[selector]['Upgrade'][1:-1].split(',')
            upgrade_list.remove('e001')  # Ignore Race Selector (e001)
        else:
            count += 1

        if unit_data[selector]['Trains'] != '""':
            trained_list = unit_data[selector]['Trains'][1:-1].split(',')
            set_hotkeys(unit_data, upgrade_list + trained_list, selector, **kwargs)
        else:
            count += 1

        if count == 2:
            print(f'Empty selector: [{selector}]')

def configure_decorations(unit_data, **kwargs):
    keys = ('Buttonpos_2', 'Buttonpos_1', 'Hotkey')
    get_build_list = lambda x: x['Builds'][1:-1].split(',')
    misc = set(get_build_list(unit_data['u00W']))  # Ignore anything built by Deco Builder Misc (includes spawners)
    ignore = lambda d: d.name in misc or ('EditorSuffix' in d and '[spawn]' in d['EditorSuffix'])
    for decoration in (unit_data[d] for d in get_decorations(unit_data) if not ignore(unit_data[d])):
        for key in itertools.chain(keys, kwargs):
            if key in decoration: del decoration[key]
    for builder in iter_deco_builders(unit_data, builder_only=True):
        if builder.name != 'u00W':
            set_hotkeys(unit_data, get_build_list(builder), builder, **kwargs)



file_path = '../development/table/unit.ini'

def do(file_path=file_path, simple=True):
    with open(file_path) as f:
        unit_data = load_unit_data(f)

    has_tag = lambda x,tag: 'EditorSuffix' in unit_data[x] and tag in unit_data[x]['EditorSuffix']
    buildings = [x for x in unit_data if has_tag(x,'[prod]')]
    selectors = [x for x in unit_data if has_tag(x,'[sele]')]
    
    if simple:
        configure_trained_units(unit_data, buildings)
        configure_selectors(unit_data, selectors)
        configure_decorations(unit_data)
    else:
        tip_lambda = lambda x: '"{} - [|cffffcc00{}|r]"'.format(x['Name'][1:-1], x['Hotkey'][1:-1])
        ubertip_lambda = lambda x: '""' if 'Ubertip' not in x else x['Ubertip']
        configure_trained_units(unit_data, buildings, Tip=tip_lambda, Ubertip=ubertip_lambda, bldtm='2', fused='0', goldcost='0', lumbercost='0')
        configure_selectors(unit_data, selectors, Tip=tip_lambda, Ubertip=ubertip_lambda, bldtm='1', fused='0', goldcost='0', lumbercost='0')
        configure_decorations(unit_data, Tip=tip_lambda)

    with open(file_path, 'w') as f:
        unit_data.write(f)
