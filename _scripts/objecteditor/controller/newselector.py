import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings
from ..view import newselector
from . import get_string_unit
import traceback
from myconfigparser import Section

def open_window(data):
    options, strings = [], {}

    def populate():
        nonlocal strings
        options.clear()
        for u in data:
            unit = Section(data[u])
            if '[sele]' in unit['EditorSuffix'] or u =='e001':
                options.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]))
                
        strings = map_substrings(options)

    populate()

    window = sg.Window('New Selector', newselector.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(options)

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            try:
                ObjectData(data).create_selector(values['Name'], get_string_unit(values['Options'][0]))
                populate()
                sg.popup('Success')
            except Exception as e:
                sg.popup(str(e), traceback.format_exc(),title='Error')

        search = values['Search'].lower()
        if search in strings:
            window.find_element('Options').Update(strings[search])
        else:
            window.find_element('Options').Update(options)