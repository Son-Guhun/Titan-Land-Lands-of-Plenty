import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings
from ..view import newunit

from myconfigparser import Section

get_string_unit = lambda string: string[-5:-1]


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
    for u in data:
        unit = Section(data[u])
        if '[prod]' in unit['EditorSuffix']:
            options.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]))
            
    strings = map_substrings(options)


    window = sg.Window('New Unit', newunit.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(options)

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            sg.popup('Success')
        else:
            search = values['Search'].lower()
            if search in strings:
                current = strings[search]
            else:
                current = options

            race = values['Race']
            if race != 'Any':
                current = [string for string in current if Section(data[get_string_unit(string)])['race'][1:-1] in races[race]]

            mode = values['Mode']
            if mode != 'Both':
                mode = '1' if mode == 'Reforged' else '0'
                current = [string for string in current if Section(data[get_string_unit(string)])['campaign'] == mode]

            window.find_element('Options').Update(current)