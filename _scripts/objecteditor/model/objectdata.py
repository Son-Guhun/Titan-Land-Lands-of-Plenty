# -*- coding: utf-8 -*-
EMPTY = '""'

def append_rawcode(unit, field, rawcode):
    stuff = unit['Upgrade'][1:-1].split(',') if 'Upgrade' in unit else []
    stuff.append(rawcode)
    unit['Upgrades'] = '"{}"'.format(','.join(stuff))

class ObjectData:

    def __init__(self, data):
        self.data = data

    def create_selector(self, name, parent):
        data = self.data
        rawcode = data.new_rawcode('E001')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = 'e001'
        unit = data[rawcode]
        parent = data[parent]

        unit['Name'] = name
        unit['Upgrade'] = EMPTY
        unit['Trains'] = EMPTY
        append_rawcode(parent, 'Upgrade', rawcode)
        
    def create_worker(self, name, selector):
        data = self.data
        rawcode = data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = 'hpea'
        unit = data[rawcode]
        selector = data[selector]

        unit['Name'] = name
        unit['Builds'] = EMPTY
        append_rawcode(selector, 'Trains', rawcode)

    def create_production(self, name, worker, race):
        data = self.data
        rawcode = data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = 'hbar'
        unit = data[rawcode]
        worker = data[worker]
        
        unit['Name'] = name
        unit['Trains'] = EMPTY
        append_rawcode(worker, 'Builds', rawcode)

    def create_unit(self, name, production, base):
        data = self.data
        rawcode = data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = base
        unit = data[rawcode]
        production = data[production]
        
        unit['Name'] = name
        append_rawcode(production, 'Trains', rawcode)

