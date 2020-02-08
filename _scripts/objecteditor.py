#!/usr/bin/env Python3
import PySimpleGUI as sg
from myconfigparser import load_unit_data, Section, UnitParser


from objecteditor.controller import newselector, newworker, newproduction, newunit
from objecteditor.controller import newtower, newhero
from objecteditor.controller import newdecobuilder, newdecoration, newvariation

dataBase = '../development/table/unit.ini'

with open(dataBase) as f:
    data = load_unit_data(f, parser=UnitParser)

layout = [
    [sg.Text('Racial Units')],
    [sg.Button('New Selector', key='New Selector')],
    [sg.Button('New Worker', key='New Worker')],
    [sg.Button('New Production', key='New Production')],
    [sg.Button('New Unit', key='New Unit')],
    [sg.Text('Heroes')],
    [sg.Button('New Tower', key='New Tower')],
    [sg.Button('New Hero', key='New Hero')],
    [sg.Text('Decorations')],
    [sg.Button('New Deco Builder', key='New Deco Builder')],
    [sg.Button('New Decoration', key='New Decoration')],
    [sg.Button('New Variation', key='New Variation')],
    [sg.Text('____________')],
    [sg.Submit(tooltip='Click to submit this window')]    
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
        elif event == 'Submit':
            with open(dataBase, 'w') as f:
                data.write(f)
        # Units
        elif event == 'New Selector':
            show_window(newselector)
        elif event == 'New Worker':
            show_window(newworker)
        elif event == 'New Production':
            show_window(newproduction)
        elif event == 'New Unit':
            show_window(newunit)
        # Heroes
        elif event == 'New Tower':
            show_window(newtower)
        elif event == 'New Hero':
            show_window(newhero)
        # Decorations
        elif event == 'New Deco Builder':
            show_window(newdecobuilder)
        elif event == 'New Decoration':
            show_window(newdecoration)
        elif event == 'New Variation':
            show_window(newvariation)