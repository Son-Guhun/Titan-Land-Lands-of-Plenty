# -*- coding: utf-8 -*-
from myconfigparser import Section
EMPTY = '""'

def count_fields(unit, *args):
    result = 0 if 'Aro1' not in Section(unit)['abilList'] else 1
    for field in args:
        if field in unit:
            if unit[field] != '""':
                result += unit[field].count(',') + 1
    return result

def append_rawcode(unit, field, rawcode):
    stuff = unit[field][1:-1].split(',') if field in unit else []
    stuff.append(rawcode)
    unit[field] = '"{}"'.format(','.join(stuff))

class ObjectData:

    def __init__(self, data):
        self.data = data

    def create_selector(self, name, parent):
        data = self.data
        rawcode = data.new_rawcode('E000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data['e037']
        unit = data[rawcode]
        parent = data[parent]

        unit['Name'] = '"{}"'.format(name)
        unit['Upgrade'] = EMPTY
        unit['Trains'] = EMPTY
        unit['campaign'] = parent['campaign']

        print(unit['EditorSuffix'])
        if count_fields(parent, 'Upgrade', 'Trains') < 12:
            append_rawcode(parent, 'Upgrade', rawcode)
        else:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Upgrade', parent.name))
        
    def create_worker(self, name, selector):
        data = self.data
        rawcode = data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data['hpea']
        unit = data[rawcode]
        selector = data[selector]

        unit['Name'] = '"{}"'.format(name)
        unit['Builds'] = EMPTY
        unit['campaign'] = Section(selector)['campaign']

        if count_fields(selector, 'Upgrade', 'Trains') < 12:
            append_rawcode(selector, 'Trains', rawcode)
        else:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Trains', selector.name))

    BUILDINGS = {
        'human': 'hbar',
        'orc': 'obar',
        'undead': 'usep',
        'nightelf': 'edob',
        'naga': 'nnsa'
    }

    def create_production(self, name, worker, race):
        data = self.data
        base = self.BUILDINGS[race] if race in self.BUILDINGS else 'hbar'
        rawcode = data.new_rawcode(base[0].upper() + '000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data[base]
        unit = data[rawcode]
        worker = data[worker]
        
        unit['Name'] = '"{}"'.format(name)
        unit['Trains'] = EMPTY
        unit['race'] = '"{}"'.format(race)
        unit['campaign'] = Section(worker)['campaign']
        if count_fields(worker, 'Builds') < 12:
            append_rawcode(worker, 'Builds', rawcode)
        else:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Builds', worker.name))

    def _create_upgrade(self, prev, next):
        data = self.data
        rawcode = data.new_rawcode(prev[0].upper() + '000')
        rawcode = rawcode[0].lower() + rawcode[1:]
 
        prev = data[prev]
        next = data[next]
        data[rawcode] = prev
        unit = data[rawcode]

        trained = prev['Trains'][1:-1].split(',')
        last_trained = trained[-1]
        del trained[-1]
        prev['Trains'] = '"{}"'.format(','.join(trained))
        prev['Upgrade'] = '"{}"'.format(unit.name)
        
        unit['Name'] = '"{}"'.format(Section(prev)['Name'][1:-1] + ' (New)')
        unit['Trains'] = '"{}"'.format(last_trained)
        unit['Upgrade'] = '"{}"'.format(next.name)

        print(unit.name)
        return data[unit.name]

    def create_unit(self, name, production, base):
        data = self.data
        rawcode = data.new_rawcode(base[0].upper() + '000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data[base]
        unit = data[rawcode]
        first = production
        production = data[production]

        while count_fields(production, 'Upgrade', 'Trains') >= 12:
            upgrade = Section(production)['Upgrade'][1:-1]
            print(upgrade)
            if upgrade == '' or upgrade == first:
                production = self._create_upgrade(production.name, first)
            else:
                production = data[upgrade]

        unit['Name'] = '"{}"'.format(name)
        unit['race'] = Section(production)['race']
        unit['campaign'] = Section(production)['campaign']
        append_rawcode(production, 'Trains', rawcode)

