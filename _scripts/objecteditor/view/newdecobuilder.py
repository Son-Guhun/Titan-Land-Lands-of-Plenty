import PySimpleGUI as sg
from . import menu

sg.ChangeLookAndFeel('GreenTan') 

def get_layout():
    return [
        [sg.Menu(menu.menu_def, tearoff=True)],
        [sg.Text('Deco Builder Name')],
        [sg.Input(key ='Name'), sg.InputCombo(('Classic', 'Reforged'),default_value='Classic',key='Mode')],
        [sg.Submit(tooltip='Click to submit this window')]    
    ]
