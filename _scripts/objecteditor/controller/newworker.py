import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings
from ..view import newworker
from . import get_string_unit, RACES
from myconfigparser import Section
import traceback

def open_window(data):
    options = []
    for u in data:
        unit = Section(data[u])
        if '[sele]' in unit['EditorSuffix'] or u =='e001':
            options.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]))
            
    strings = map_substrings(options)


    window = sg.Window('New Worker', newworker.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(options)

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            try:
                ObjectData(data).create_worker(values['Name'], get_string_unit(values['Options'][0]), RACES[values['Race']])
                sg.popup('Success')
            except Exception as e:
                sg.popup(str(e), traceback.format_exc(),title='Error')
                

        search = values['Search'].lower()
        if search in strings:
            current = strings[search]
        else:
            current = options

        mode = values['Mode']
        if mode != 'Both':
            mode = '1' if mode == 'Reforged' else '0'
            current = [string for string in current if Section(data[get_string_unit(string)])['campaign'] == mode]

        window.find_element('Options').Update(current)

       