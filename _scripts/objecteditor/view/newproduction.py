import PySimpleGUI as sg
from . import menu
from . import RACES

sg.ChangeLookAndFeel('GreenTan') 

def get_layout():
    return [
        [sg.Menu(menu.menu_def, tearoff=True)],
        [sg.Text('Production Name')],
        [sg.Input(key ='Name'), sg.InputCombo(RACES, default_value='Human', key='Race')],
        [sg.Text('Built by:')],
        [sg.Input(enable_events=True, key ='Search', tooltip='Search for a unit.')],
        [sg.Listbox('', select_mode=sg.LISTBOX_SELECT_MODE_BROWSE, size=(30, 10),key='Options')],
        [sg.Submit(tooltip='Click to submit this window')]    
    ]