import PySimpleGUI as sg
from . import menu

sg.ChangeLookAndFeel('GreenTan') 

layout = [
    [sg.Menu(menu.menu_def, tearoff=True)],
    [sg.Text('Unit Name')],
    [sg.Input(change_submits=True, key ='Search')],
    [sg.Text('Unit Parent')],
    [sg.Listbox('',size=(30, 10),key='Options')],      
    [sg.Submit(tooltip='Click to submit this window'), sg.Cancel()]    
]      
