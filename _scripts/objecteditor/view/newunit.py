import PySimpleGUI as sg
from . import menu
from . import RACES

sg.ChangeLookAndFeel('GreenTan') 

def get_layout():
    return [
        [sg.Menu(menu.menu_def, tearoff=True)],
        [sg.Text('Unit Name')],
        [sg.Input(key ='Name')],
        [sg.Text('Trained by:')],
        [
            sg.Input(enable_events=True, key ='Search', tooltip='Search for a unit.'),
            sg.InputCombo(('Any',)+RACES,default_value='Any',enable_events=True,key='Race'),
            sg.InputCombo(('Both', 'Classic', 'Reforged'),default_value='Both',enable_events=True,key='Mode')
        ],
        [sg.Listbox('',size=(30, 10),key='Options')],
        [sg.Submit(tooltip='Click to submit this window'), sg.Cancel()]    
    ]
