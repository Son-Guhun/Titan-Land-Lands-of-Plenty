from myconfigparser import MyConfigParser, load_unit_data, get_decorations

HOTKEYS = ['Q','W','E','R',
           'A','S','D','F',
           'Z','X','C','V']
for i,hotkey in enumerate(HOTKEYS):
    HOTKEYS[i] = '"{}"'.format(hotkey)

def set_hotkeys(unit_data, unit_list):
    for i,unit in enumerate(unit_list):
        #if i > 6:
        #    i += 1  # Skip rally point ability
        try:
            unit = unit_data[unit]
            unit['Buttonpos_2'] = str(i//4)
            unit['Buttonpos_1'] = str(i%4)
            unit['Hotkey'] = HOTKEYS[i]
        except KeyError:
            print('Could not find data for trained unit: ' + unit)
            # print(building + ":", unit_data[building]["Trains"])


def configure_trained_units(unit_data, building_list):
    for building in building_list:
        try:
            trained_list = unit_data[building]['Trains'][1:-1].split(',')
            set_hotkeys(unit_data, trained_list)
        except KeyError:
            print('Could not find any units trained by: ' + building)
        except Exception as e:
            print('Exception in building: ' + building)
            print(unit_data[building]["Trains"][1:-1].split(','))
            print(e)

def configure_selectors(unit_data, selector_list):
    for selector in selector_list:
        upgrade_list = unit_data[selector]['Upgrade'][1:-1].split(',')
        upgrade_list.remove('e001')
        trained_list = unit_data[selector]['Trains'][1:-1].split(',')
        set_hotkeys(unit_data, upgrade_list + trained_list)
        
        
    

def do_everything(file_path, buildings=[], selectors=[]):
    with open(file_path) as f:
        unit_data = load_unit_data(f)
        
    configure_trained_units(unit_data, buildings)
    configure_selectors(unit_data, selectors)

    with open(file_path, 'w') as f:
        unit_data.write(f)


file_path = '../development/table/unit.ini'
buildings = [
    'h00L', # Bandit
    'h0T0', # Bandit Magic
    'h085', # Black Legion
    'h086', # Black Legion Magic
    'h00K', # Dwarven
    'h0N8', # Dwarven Magic
    'h0J2', # Angel
    'h0HQ', # Haradrim
    'h0HR', # Haradrim Magic
    'hbar', # Human
    'h0PT', # Human Magic
    'h0RJ', # Lordaeron
    'h02Y', # Nihonjin
    'h09J', # Nihonjin Magic
    ]

selectors = [
    'e005', # Corrupted
    'e039', # Corrupted (Demons)
    'e037', # Corrupted (Undead)
    'e004', # Creeps
    'e00V', # Elves
    'e002', # Humans and Dwarves
    'e00F', # Naga and Murlocs
    'e003', # Orcs, Ogres, Trolls, Tauren
    ]
