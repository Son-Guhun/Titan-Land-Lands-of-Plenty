import PySimpleGUI as sg
from ..model.objectdata import ObjectData
from ..model.search import map_substrings
from ..view import newtower
from . import get_string_unit
import traceback
from myconfigparser import Section

def open_window(data):
    window = sg.Window('New Hero Tower', newtower.get_layout(), default_element_size=(40, 1), grab_anywhere=False)   

    while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'Submit':
            try:
                ObjectData(data).create_tower(values['Name'])
                sg.popup('Success')
            except Exception as e:
                sg.popup(str(e), traceback.format_exc(),title='Error')