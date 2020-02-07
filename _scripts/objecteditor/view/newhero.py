import PySimpleGUI as sg
from . import menu
from . import RACES

sg.ChangeLookAndFeel('GreenTan') 

def get_layout():
    return [
        [sg.Menu(menu.menu_def, tearoff=True)],
        [sg.Text('Proper Name')],
        [sg.Input(key ='ProperName')],
        [sg.Text('Class Name')],
        [sg.Input(key ='Name'), sg.InputCombo(RACES, default_value='Human', key='Race')],
        [sg.Text('Hero Tower:')],
        [
            sg.Input(enable_events=True, key ='Search 1', tooltip='Search for a unit.'),
            sg.InputCombo(('Both', 'Classic', 'Reforged'),default_value='Both',enable_events=True,key='Mode 1')
        ],
        [sg.Listbox('', select_mode=sg.LISTBOX_SELECT_MODE_BROWSE, size=(30, 10),key='Options 1')],
        [sg.Text('Base hero:')],
        [
            sg.Input(enable_events=True, key ='Search 2', tooltip='Search for a unit.'),
            sg.InputCombo(('Any',)+RACES,default_value='Any',enable_events=True,key='Race 2'),
            sg.InputCombo(('Both', 'Classic', 'Reforged'),default_value='Both',enable_events=True,key='Mode 2')
        ],
        [sg.Listbox('', select_mode=sg.LISTBOX_SELECT_MODE_BROWSE, size=(30, 10),key='Options 2')],
        [sg.Submit(tooltip='Click to submit this window')]    
    ]
