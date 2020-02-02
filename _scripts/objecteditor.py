#!/usr/bin/env Python3
import PySimpleGUI as sg
from myconfigparser import load_unit_data, Section


from objecteditor.controller.newselector import open_window

dataBase = '../development/table/unit.ini'

with open(dataBase) as f:
    data = load_unit_data(f)

layout = [
    [sg.Button('New Selector', key='New Selector')]
]

window = sg.Window('Everything bagel', layout)

while True:
        event, values = window.read()

        if event is None:
            break
        elif event == 'New Selector':
            window.Hide()
            open_window(data)
            window.UnHide()
