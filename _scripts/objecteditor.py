#!/usr/bin/env Python3
import PySimpleGUI as sg
from myconfigparser import load_unit_data, Section


from objecteditor.view import newselector
from objecteditor.model.search import map_substrings

dataBase = '../development/table/unit.ini'

with open(dataBase) as f:
    data = load_unit_data(f)

options = []
for u in data:
    unit = Section(data[u])
    if '[sele]' in unit['EditorSuffix'] or u =='e001':
        options.append('{name} [{code}]'.format(code=u, name=unit['Name'][1:-1]))
        
strings = map_substrings(options)


window = sg.Window('Everything bagel', newselector.layout, default_element_size=(40, 1), grab_anywhere=False).Finalize()     
window.find_element('Options').Update(options)

while True:
    event, values = window.read()

    search = values['Search'].lower()
    if search in strings:
        window.find_element('Options').Update(strings[search])
    else:
        window.find_element('Options').Update(options)

    if event is None:
        break
