import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import SearchableList
from ..view import newvariation
from . import get_string_unit, filter_listbox

from myconfigparser import Section

def open_window(data):
    options = SearchableList()
    for d in data:
        deco = Section(data[d])
        if 'A00J' in deco['abilList']:
            for u in deco['Builds'][1:-1].split(','):
                if u != '':
                    options.append('{name} [{code}]'.format(code=u, name=Section(data[u])['Name'][1:-1]))
    
    window = sg.Window('New Variation', newvariation.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(sorted(options))

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            try:
                u = ObjectData(data).create_variation(values['Name'], values['Model'], get_string_unit(values['Options'][0]))
                sg.popup('Success, created: ' + data[u]['Name'][1:-1])
            except Exception as e:
                sg.popup(str(e),title='Error')

        filter_listbox(data, window, values, '', options)

