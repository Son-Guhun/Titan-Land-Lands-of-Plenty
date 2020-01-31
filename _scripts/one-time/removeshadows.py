# -*- coding: utf-8 -*-
"""
Created on Sat Jan 18 22:05:21 2020

@author: SonGuhun

This script is used to remove shadows from units which have large shadows. It was
determined that large shadow images could cause crash when on water near the map
borders.
"""

from myconfigparser import Section, load_unit_data



dataBase = "..\\development\\table\\unit.ini"


def do(dataBase=dataBase):

    with open(dataBase) as f:
        data = load_unit_data(f)
    
    
    for unit in (Section(data[u]) for u in data):
        if float(unit['shadowH']) > 200 or float(unit['shadowW']) > 200:
            unit['unitShadow'] = unit['buildingShadow'] = '""'
            
    with open(dataBase, 'w') as f:
        data.write(f)

