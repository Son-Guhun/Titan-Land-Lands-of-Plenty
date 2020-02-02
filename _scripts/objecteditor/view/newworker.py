import PySimpleGUI as sg
from . import menu

sg.ChangeLookAndFeel('GreenTan') 

def get_layout():
    return [
        [sg.Menu(menu.menu_def, tearoff=True)],
        [sg.Text('Worker Name')],
        [sg.Input(key ='Name')],
        [sg.Text('Selector')],
        [sg.Input(enable_events=True, key ='Search', tooltip='Search for a unit.')],
        [sg.Listbox('',size=(30, 10),key='Options')],
        [sg.Submit(tooltip='Click to submit this window'), sg.Cancel()]    
    ]
