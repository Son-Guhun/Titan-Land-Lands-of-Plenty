#!/usr/bin/env Python3
import PySimpleGUI as sg
from myconfigparser import load_unit_data, Section
from objecteditor.view import newselector

dataBase = '../development/table/unit.ini'

def get_substrings(string):
    "Returns all possible substrings of a string."
    return [string[i: j] for i in range(len(string)) 
          for j in range(i + 1, len(string) + 1)]

def map_substrings(deco_names):
    """
    Returns a map of (substrings)->(rawcodes), i.e. a map from each substring
    to all units whose name includes that substrings.
    """
    stuff = {}
    for string in deco_names:
        for substring in get_substrings(string):
            if substring not in stuff:
                stuff[substring] = [string]
            else:
                stuff[substring].append(string)
    return stuff

with open(dataBase) as f:
    data = load_unit_data(f)

options = []
strings = []
for u in data:
    unit = Section(data[u])
    if '[sele]' in unit['EditorSuffix'] or u =='e001':
        options.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]))
        strings.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]).lower())
        
strings = map_substrings(strings)

sg.ChangeLookAndFeel('GreenTan')      

# ------ Menu Definition ------ #      
menu_def = [['File', ['Open', 'Save', 'Exit', 'Properties']],      
            ['Edit', ['Paste', ['Special', 'Normal', ], 'Undo'], ],      
            ['Help', 'About...'], ]      


window = sg.Window('Everything bagel', newselector.layout, default_element_size=(40, 1), grab_anywhere=False)      

while True:
    event, values = window.read()      

##    sg.popup('Title',      
##                'The results of the window.',      
##                'The button clicked was "{}"'.format(event),      
##                'The values are', values)
    if values['a'].lower() in strings:
        window.find_element('b').Update(strings[values['a'].lower()])

    if event is None:
        break
