"""This script iterates over a pre-defined list of buildings in a .ini database and assigns hotkeys to all units produced by those buildings.

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
buildings = [
    # Human
    'hgra',  # Gryphon Aviary
    'harm',  # Workshop
    
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
    'h0NF',  # Norse
    'h0Q2',  # Norse Magic
    'h06C',  # Pandaren
    'h06E',  # Pandaren Magic
    'h005',  # Pirate
    'h06H',  # Rostrodle
    'h06M',  # Rostrodle Magic
    'h0DY',  # Runic
    'h0DZ',  # Runic Magic
    'h0RP',  # Stormwind
    'h05X',  # Templar
    'h05Y',  # Templar Magic
    'h0A1',  # Templar Fort
    'h0ZY',  # Worgen
    'h100',  # Worgen Magic

    # Orc
    'obar',  # Barracks
    'obea',  # Bestiary
    'otto',  # Tauren Totem
    
    'o02V',  # Centuar
    'o00O',  # Fel Orc
    'o00P',  # Fel Orc Bestiary
    'o00Q',  # Fel Orc Magic
    'o02F',  # Goblin Magic
    'o02D',  # Goblin
    'o005',  # Ogre
    'o008',  # Ogre Magic
    'o00Y',  # Razormane
    'o00V',  # Son'Gar
    'o00W',  # Son'Gar Magic
    'o020',  # Tauren
    'o00K',  # Troll Darkspear
    'o01Q',  # Troll Forest
    'o01R',  # Troll Ice
    'o01C',  # Troll Raptor
    'o025',  # Troll Magic

    # Undead
    'usep',  # Flesh
    'uslh',  # Flesh Magic
    'ubon',  # Fleshless Magic
    'utod',  # Fleshless
    'usap',  # Incorporeal
    'ugrv',  # Incorporeal Magic
    
    'u04M',  # Cultist Magic
    'u04L',  # Cultist
    'u051',  # Dark Dwarf Magic
    'u052',  # Dark Dwarf
    'u05I',  # Dark Human
    'u05H',  # Dark Human Magic
    'u01H',  # Demon
    'u01I',  # Demon Magic
    'u049',  # Faceless Magic
    'u04D',  # Faceless
    'u05O',  # Fel Elf Magic
    'e03M',  # Fel Elf
    'u05Q',  # Fel Troll Magic
    'u05P',  # Fel Troll
    'u05B',  # Embalmed
    'u05C',  # Embalmed Magic
    'u04T',  # Vampire
    'u04V',  # Vampire Magic

    # Night Elf
    'nheb',  # Blood Elf
    'hars',  # Blood Elf Magic
    'edob',  # Night Elf
    'nbwd',  # Night Elf Magic
    
    'e011',  # Draenei
    'e012',  # Draenei Magic
    'e00Y',  # Drow Magic
    'e00K',  # Drow
    'e02B',  # Forest Elf Magic
    'e02C',  # Forest Elf
    'h0TU',  # Gray Elf
    'h0TT',  # Gray Elf Magic
    'h06N',  # High Elf Magic
    'h06O',  # High Elf
    'h101',  # Middle-earth Elvwes
    'e02O',  # Wood Elf

    # Naga
    'nnsa',  # Shrine of Azshara
    'nnsg',  # Spawning Grounds

    'n009',  # Murloc
    'n00A',  # Murloc Magic

    # Creep
    'eaom',  # Forest Dwellers
    'eaoe',  # Forest Dwellers Magic
    'eaow',  # Forest Dwellers Flyers
    
    'h0G9',  # Elemental
    'h0G8',  # Elemental Magic
    'h12L',  # Lizardman
    'h12M',  # Lizardman Magic
    'h11U',  # Ratfolk
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
        configure_trained_units(unit_data, buildings, Tip=tip_lambda, Ubertip=ubertip_lambda, bldtm='2', fused='0', goldcost='0', lumbercost='0')
        configure_selectors(unit_data, selectors, Tip=tip_lambda, Ubertip=ubertip_lambda, bldtm='1', fused='0', goldcost='0', lumbercost='0')

    with open(file_path, 'w') as f:
        unit_data.write(f)
