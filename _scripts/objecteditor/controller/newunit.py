import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings
from ..view import newunit
from . import get_string_unit

from myconfigparser import Section


races = {
    'Human': ['human'],
    'Orc': ['orc'],
    'Undead': ['undead'],
    'Night Elf': ['nightelf'],
    'Naga': ['naga'],
    'Creep': set(['commoner','creeps','critters','demon','other','unkown'])
}

def open_window(data):
    options = []
    options2 = set()

    for s in data:
        structure = Section(data[s])
        if '[prod]' in structure['EditorSuffix']:
            options.append('{name} [{code}]'.format(code=s, name=structure['Name'][1:-1]))
            for u in structure['Trains'][1:-1].split(','):
                if u != '':
                    options2.add('{name} [{code}]'.format(code=u, name=Section(data[u])['Name'][1:-1]))
    
    options2 = sorted(options2)
            
    strings = map_substrings(options)
    strings2 = map_substrings(options2)


    window = sg.Window('New Unit', newunit.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(options)
    window.find_element('Options 2').Update(options2)

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            ObjectData(data).create_unit(values['Name'], get_string_unit(values['Options'][0]), get_string_unit(values['Options 2'][0]))
            sg.popup('Success')
        else:
            def a(a, stuff, stuff2):
                search = values['Search'+a].lower()
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

                window.find_element('Options'+a).Update(sorted(current))
            a('', options, strings)
            a(' 2', options2, strings2)