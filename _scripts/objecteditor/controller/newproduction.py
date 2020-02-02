import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings
from ..view import newproduction

from myconfigparser import Section

def open_window(data):
    options = []
    for u in data:
        unit = Section(data[u])
        if unit['Builds'] != '""' and u != 'e000' and 'A00J' not in unit['abilList']:
            options.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]))
            
    strings = map_substrings(options)


    window = sg.Window('New Production', newproduction.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(options)

    while True:
        event, values = window.read()

        if event == 'Search':
            search = values['Search'].lower()
            if search in strings:
                window.find_element('Options').Update(strings[search])
            else:
                window.find_element('Options').Update(options)

        if event is None:
            break
        elif event == 'Submit':
            sg.popup('Success')