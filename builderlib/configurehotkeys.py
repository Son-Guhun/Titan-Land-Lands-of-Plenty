"""This script iterates over all production buildings (see tags) in a .ini database and assigns hotkeys to all units produced by those buildings.

Hotkey order: [Q,W,E,R,A,S,D,F,Z,W,C,V]
Production buildings: sets hotkeys for trained units in the order that they appear.
Race Selectors: configures hotkeys for upgrades, then for trained units, in the order that each appears.

"""

from myconfigparser import MyConfigParser, load_unit_data, get_decorations
import traceback

HOTKEYS = ['"Q"','"W"','"E"','"R"',
           '"A"','"S"','"D"','"F"',
           '"Z"','"X"','"C"','"V"']

def set_hotkeys(unit_data, unit_list, **kwargs):
    for i,unit in enumerate(unit_list):
        #if i > 6:
        #    i += 1  # Skip rally point ability
        try:
            unit = unit_data[unit]
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
                    traceback.print_exc()
        except KeyError:
            print('Could not find data for trained unit: ' + unit)

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
                    upgrade = unit_data[upgrade]['Upgrade'][1:-1]
                    if len(series) > MAX_UPGRADES:
                        raise ValueError('Could not find original building ({}) in upgrade depth of {}.'.format(building, MAX_UPGRADES))
            
            for structure in series:
                try:
                    trained_list = unit_data[structure]['Trains'][1:-1].split(',')
                    set_hotkeys(unit_data, trained_list, **kwargs)
                except KeyError:
                    print('Could not find any units trained by: ' + building)
        except Exception as e:
            print('Exception in building: ' + building)
            traceback.print_exc()

def configure_selectors(unit_data, selector_list, **kwargs):
    for selector in selector_list:
        upgrade_list = unit_data[selector]['Upgrade'][1:-1].split(',')
        upgrade_list.remove('e001')  # Ignore Race Selector (e001)

        trained_list = unit_data[selector]['Trains'][1:-1].split(',')
        set_hotkeys(unit_data, upgrade_list + trained_list, **kwargs)



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
    else:
        tip_lambda = lambda x: '"{} - [|cffffcc00{}|r]"'.format(x['Name'][1:-1], x['Hotkey'][1:-1])
        ubertip_lambda = lambda x: '""' if 'Ubertip' not in x else x['Ubertip']
        configure_trained_units(unit_data, buildings, Tip=tip_lambda, Ubertip=ubertip_lambda, bldtm='2', fused='0', goldcost='0', lumbercost='0')
        configure_selectors(unit_data, selectors, Tip=tip_lambda, Ubertip=ubertip_lambda, bldtm='1', fused='0', goldcost='0', lumbercost='0')

    with open(file_path, 'w') as f:
        unit_data.write(f)
