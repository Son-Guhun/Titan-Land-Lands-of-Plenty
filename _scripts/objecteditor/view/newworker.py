import PySimpleGUI as sg
from . import menu
from . import RACES

RACES = list(RACES)
RACES.remove('Creep')

sg.ChangeLookAndFeel('GreenTan') 

def get_layout():
    return [
        [sg.Menu(menu.menu_def, tearoff=True)],
        [sg.Text('Worker Name')],
        [sg.Input(key ='Name'), sg.InputCombo(RACES,default_value=RACES[0],enable_events=True,key='Race')],
        [sg.Text('Selector')],
        [
            sg.Input(enable_events=True, key ='Search', tooltip='Search for a unit.'),
            sg.InputCombo(('Both', 'Classic', 'Reforged'),default_value='Both',enable_events=True,key='Mode')
        ],
        [sg.Listbox('',size=(30, 10),key='Options')],
        [sg.Submit(tooltip='Click to submit this window')]    
    ]
