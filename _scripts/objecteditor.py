#!/usr/bin/env Python3
import PySimpleGUI as sg
from myconfigparser import load_unit_data, Section


from objecteditor.controller.newselector import open_window

dataBase = '../development/table/unit.ini'

with open(dataBase) as f:
    data = load_unit_data(f)

open_window(data)
