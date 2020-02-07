import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings, add_to_map
from ..view import newhero
from . import get_string_unit, filter_listbox, RACES
import traceback
from myconfigparser import Section

def open_window(data):
    options = []
    options2 = []

    for t in data:
        tower = Section(data[t])
        if tower['Name'][1:-1].startswith('Tower: '):
            options.append('{name} [{code}]'.format(code=t, name=tower['Name'][1:-1]))
            for u in tower['Sellunits'][1:-1].split(','):
                if u != '':
                    unit = Section(data[u])
                    if unit['campaign'] == '1':
                        name = unit['Propernames'][1:-1]
                    else:
                        name = unit['Name'][1:-1]

                    if name.startswith('_HD '):
                        name = name[4:]
                    
                    options2.append('{name} [{code}]'.format(code=u, name=name))

            
    strings = map_substrings(options)
    strings2 = map_substrings(options2)

    window = sg.Window('New Selector', newhero.get_layout(), default_element_size=(40, 1), grab_anywhere=False).Finalize()     
    window.find_element('Options 1').Update(sorted(options))
    window.find_element('Options 2').Update(sorted(options2))

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            try:
                u = ObjectData(data).create_hero(values['Name'], values['ProperName'], get_string_unit(values['Options 1'][0]), RACES[values['Race']], get_string_unit(values['Options 2'][0]))
                unit = Section(data[u])
                if unit['campaign'] == '1':
                    name = unit['Propernames'][1:-1]
                else:
                    name = unit['Name'][1:-1]

                if name.startswith('_HD '):
                    name = name[4:]
                
                options2.append('{name} [{code}]'.format(code=u, name=name))
                add_to_map(strings2, options2[-1])
                sg.popup('Success')
            except Exception as e:
                sg.popup(str(e), traceback.format_exc(),title='Error')


        filter_listbox(data, window, values, ' 1', options, strings)
        filter_listbox(data, window, values, ' 2', options2, strings2)
