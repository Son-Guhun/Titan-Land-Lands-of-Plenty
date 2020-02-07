import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings, add_to_map
from ..view import newunit
from . import get_string_unit
from ..model import Production

from myconfigparser import Section, DEFAULTS


races = {
    'Human': ['human'],
    'Orc': ['orc'],
    'Undead': ['undead'],
    'Night Elf': ['nightelf'],
    'Naga': ['naga'],
    'Creep': set(['commoner','creeps','critters','demon','other','unkown'])
}

template = '{name} [{code}]'

def open_window(data):
    options = []
    options2 = set()

    for s in data:
        structure = Production(data[s])
        if '[prod]' in structure['EditorSuffix']:
            options.append(template.format(code=s, name=structure['Name'][1:-1]))
            for u in structure.trained(asString=True):
                options2.add(template.format(code=u, name=Section(data[u])['Name'][1:-1]))
    
    options2 = list(options2)
            
    strings = map_substrings(options)
    strings2 = map_substrings(options2)


    window = sg.Window('New Unit', newunit.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(sorted(options))
    window.find_element('Options 2').Update(sorted(options2))

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            u = ObjectData(data).create_unit(values['Name'], get_string_unit(values['Options'][0]), get_string_unit(values['Options 2'][0]))
            options2.append(template.format(code=u, name=Section(data[u])['Name'][1:-1]))
            add_to_map(strings2, options2[-1])
            sg.popup('Success')

        def a(a, stuff, stuff2):
            search = values['Search'+a].lower()
            if search[0:3] != 'id:':
                if search in stuff2:
                    current = stuff2[search]
                else:
                    current = stuff

                race = values['Race'+a]
                if race != 'Any':
                    current = [string for string in current if Section(data[get_string_unit(string)])['race'][1:-1] in races[race]]

                mode = values['Mode'+a]
                if mode != 'Both':
                    mode = '1' if mode == 'Reforged' else '0'
                    current = [string for string in current if Section(data[get_string_unit(string)])['campaign'] == mode]
            else:
                rawcode = values['Search'+a][3:]
                if rawcode in data:
                    current = [template.format(code=rawcode,name=Section(data[rawcode])['Name'][1:-1])]
                elif rawcode in DEFAULTS:
                    current = [template.format(code=rawcode,name=DEFAULTS[rawcode]['name'][1:-1])]
                else:
                    current = []

            window.find_element('Options'+a).Update(sorted(current))
        a('', options, strings)
        a(' 2', options2, strings2)