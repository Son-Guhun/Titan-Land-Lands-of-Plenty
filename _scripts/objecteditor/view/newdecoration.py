import PySimpleGUI as sg
from . import menu

sg.ChangeLookAndFeel('GreenTan') 

def get_layout():
    return [
        [sg.Menu(menu.menu_def, tearoff=True)],
        [sg.Text('Decoration Name')],
        [sg.Input(key ='Name')],
        [sg.Text('Model Path')],
        [sg.Input(key ='Model')],
        [sg.Text('Built by:')],
        [
            sg.Input(enable_events=True, key ='Search', tooltip='Search for a unit.'),
            sg.InputCombo(('Both', 'Classic', 'Reforged'),default_value='Both',enable_events=True,key='Mode')
        ],
        [sg.Listbox('', select_mode=sg.LISTBOX_SELECT_MODE_BROWSE, size=(30, 10),key='Options')],
        [sg.Submit(tooltip='Click to submit this window')]    
    ]
