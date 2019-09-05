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
            if 'Upgrade' in unit_data[building]:
                upgrade = unit_data[building]['Upgrade'][1:-1]
                while upgrade != building:
                    series.append(upgrade)
                    upgrade = unit_data[building]['Upgrade'][1:-1]
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
buildings = [
    'h00L',  # Bandit
    'h0T0',  # Bandit Magic
    'h085',  # Black Legion
    'h086',  # Black Legion Magic
    'h00K',  # Dwarven
    'h0N8',  # Dwarven Magic
    'h0J2',  # Angel
    'h0HQ',  # Haradrim
    'h0HR',  # Haradrim Magic
    'hbar',  # Human
    'h0PT',  # Human Magic
    'h0RJ',  # Lordaeron
    'h02Y',  # Nihonjin
    'h09J',  # Nihonjin Magic
    ]

selectors = [
    'e005',  # Corrupted
    'e039',  # Corrupted (Demons)
    'e037',  # Corrupted (Undead)
    'e004',  # Creeps
    'e00V',  # Elves
    'e002',  # Humans and Dwarves
    'e00F',  # Naga and Murlocs
    'e003',  # Orcs, Ogres, Trolls, Tauren
    ]


def do_everything(file_path=file_path, buildings=buildings, selectors=selectors, simple=True):
    with open(file_path) as f:
        unit_data = load_unit_data(f)
    
    if simple:
        configure_trained_units(unit_data, buildings)
        configure_selectors(unit_data, selectors)
    else:
        tip_lambda = lambda x: '"{} - [|cffffcc00{}|r]"'.format(x['Name'][1:-1], x['Hotkey'][1:-1])
        ubertip_lambda = lambda x: '""' if 'Ubertip' not in x else x['Ubertip']
        configure_trained_units(unit_data, buildings, Tip=tip_lambda, Ubertip=ubertip_lambda, buildtm='5', fused='0', goldcost='0', lumbercost='0')
        configure_selectors(unit_data, selectors, Tip=tip_lambda, Ubertip=ubertip_lambda, buildtm='1', fused='0', goldcost='0', lumbercost='0')

    with open(file_path, 'w') as f:
        unit_data.write(f)