from myconfigparser import MyConfigParser, load_unit_data, get_decorations

HOTKEYS = ['Q','W','E','R',
           'A','S','D','F',
           'Z','X','C','V']
for i,hotkey in enumerate(HOTKEYS):
    HOTKEYS[i] = '"{}"'.format(hotkey)

def configure_trained_units(unit_data, building_list):
    for building in building_list:
        try:
            trained_list = unit_data[building]['Trains'][1:-1].split(',')
            for i,unit in enumerate(trained_list):
                if i > 6:
                    i += 1  # Skip rally point ability
                try:
                    unit = unit_data[unit]
                    unit['Buttonpos_2'] = str(i//4)
                    unit['Buttonpos_1'] = str(i%4)
                    unit['Hotkey'] = HOTKEYS[i]
                except KeyError:
                    print('Could not find data for trained unit: ' + unit)
                    print(building + ":", unit_data[building]["Trains"])
        except KeyError:
            print('Could not find any units trained by: ' + building)
        except Exception as e:
            print('Exception in building: ' + building)
            print(unit_data[building]["Trains"][1:-1].split(','))
            print(e)

def do_everything(file_path, building_list):
    f = open(file_path)
    unit_data = load_unit_data(f)
    
    configure_trained_units(unit_data, building_list)

    f.close()
    f = open(file_path, 'w')
    unit_data.write(f)
    f.close()


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
