# -*- coding: utf-8 -*-
"""
Created on Thu Jan 16 11:07:19 2020

@author: criow
"""


layout = ['Name',
          'Parent']


layout = ['Name',
          'Spawner']


layout = ['Name',
          'Race']

layout = ['Name',
          'Base Unit']


EMPTY = '""'

def append_rawcode(unit, field, rawcode):
    stuff = unit['Upgrade'][1:-1].split(',') if 'Upgrade' in unit else []
    stuff.append(rawcode)
    unit['Upgrades'] = '"{}"'.format(','.join(stuff))

def create_selector(name, parent):
    rawcode = data.new_rawcode('E001')
    rawcode = rawcode[0].lower() + rawcode[1:]

    data[rawcode] = 'e001'
    unit = data[rawcode]
    parent = data[parent]

    unit['Name'] = name
    unit['Upgrade'] = EMPTY
    unit['Trains'] = EMPTY
    append_rawcode(parent, 'Upgrade', rawcode)
    
def create_worker(name, selector):
    rawcode = data.new_rawcode('H000')
    rawcode = rawcode[0].lower() + rawcode[1:]

    data[rawcode] = 'hpea'
    unit = data[rawcode]
    selector = data[selector]

    unit['Name'] = name
    unit['Builds'] = EMPTY
    append_rawcode(selector, 'Trains', rawcode)

def create_production(name, worker, race):
    rawcode = data.new_rawcode('H000')
    rawcode = rawcode[0].lower() + rawcode[1:]

    data[rawcode] = 'hbar'
    unit = data[rawcode]
    worker = data[worker]
    
    unit['Name'] = name
    unit['Trains'] = EMPTY
    append_rawcode(worker, 'Builds', rawcode)

def create_unit(name, production, base):
    rawcode = data.new_rawcode('H000')
    rawcode = rawcode[0].lower() + rawcode[1:]

    data[rawcode] = base
    unit = data[rawcode]
    production = data[production]
    
    unit['Name'] = name
    append_rawcode(production, 'Trains', rawcode)

