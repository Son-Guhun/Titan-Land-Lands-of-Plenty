import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings, add_to_map
from ..view import newunit
from . import get_string_unit, filter_listbox
from ..model import Production

from myconfigparser import Section, DEFAULTS

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

        filter_listbox(data, window, values, '', options, strings)
        filter_listbox(data, window, values, ' 2', options2, strings2)