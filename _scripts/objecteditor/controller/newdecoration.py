import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import SearchableList
from ..view import newdecoration
from . import get_string_unit, filter_listbox

from myconfigparser import Section

def open_window(data):
    options = SearchableList()
    for u in data:
        unit = Section(data[u])
        if 'A00J' in unit['abilList']:
            options.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]))

    window = sg.Window('New Decoration', newdecoration.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options').Update(sorted(options))

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            try:
                ObjectData(data).create_decoration(values['Name'], values['Model'], get_string_unit(values['Options'][0]), values['isBuilding'], values['PathingMap'])
                sg.popup('Success')
            except Exception as e:
                sg.popup(str(e),title='Error')
        elif event == 'isBuilding':
            window.find_element('PathingMap').Update(visible=values['isBuilding'])
            window.find_element('PathingMapText').Update(visible=values['isBuilding'])

        filter_listbox(data, window, values, '', options)
