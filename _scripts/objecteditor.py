#!/usr/bin/env Python3
import PySimpleGUI as sg
from myconfigparser import load_unit_data, Section


from objecteditor.controller import newselector
from objecteditor.controller import newworker

dataBase = '../development/table/unit.ini'

with open(dataBase) as f:
    data = load_unit_data(f)

layout = [
    [sg.Button('New Selector', key='New Selector')],
    [sg.Button('New Worker', key='New Worker')],
    [sg.Button('New Production', key='New Production')],
    [sg.Button('New Unit', key='New Unit')]
]

window = sg.Window('LoP Object Editor', layout,
                   element_justification='center')

def show_window(module):
        window.Hide()
        module.open_window(data)
        window.UnHide()

while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'New Selector':
            show_window(newselector)
        elif event == 'New Worker':
            show_window(newworker)