# -*- coding: utf-8 -*-
from myconfigparser import Section, DEFAULTS
from . import Decoration
import traceback
EMPTY = '""'

def count_fields(unit, *args):
    result = 0 if 'Aro1' not in Section(unit)['abilList'] else 1
    for field in args:
        if field in unit:
            if unit[field] != '""':
                result += unit[field].count(',') + 1
    return result

def append_rawcode(unit, field, rawcode):
    stuff = unit[field][1:-1].split(',') if field in unit and unit[field] != EMPTY else []
    stuff.append(rawcode)
    unit[field] = '"{}"'.format(','.join(stuff))

def database_safe(func):
    """This decorator is used to make sure the state of the database doesn't become invalid when an exception occurs."""
    def wrapper(self, *args, **kwargs):
        data = self.data
        backup = {section:{k:v for k,v in data[section].items()} for section in data}
        try:
            return func(self, *args, **kwargs)
        except:
            for section in backup:
                data[section] = backup[section]
            raise
    return wrapper


class ObjectData:

    def __init__(self, data):
        self.data = data

    @database_safe
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

        if count_fields(parent, 'Upgrade', 'Trains') < 12:
            append_rawcode(parent, 'Upgrade', rawcode)
        else:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Upgrade', parent.name))

    WORKERS = {
        'human': 'hpea',
        'orc': 'opeo',
        'undead': 'uaco',
        'nightelf': 'ewsp',
        'naga': 'nmpe'
    }

    @database_safe
    def create_worker(self, name, selector, race):
        data = self.data
        rawcode = data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        selector = data[selector]
        if count_fields(selector, 'Upgrade', 'Trains') >= 12:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Trains', selector.name))

        data[rawcode] = data[self.WORKERS[race]]
        unit = data[rawcode]

        unit['Name'] = '"{}"'.format(name)
        unit['Builds'] = EMPTY
        unit['campaign'] = Section(selector)['campaign']
        append_rawcode(selector, 'Trains', rawcode)
            

    BUILDINGS = {
        'human': 'hbar',
        'orc': 'obar',
        'undead': 'usep',
        'nightelf': 'edob',
        'naga': 'nnsa'
    }

    @database_safe
    def create_production(self, name, worker, race):
        data = self.data
        base = self.BUILDINGS[race] if race in self.BUILDINGS else 'hbar'
        rawcode = data.new_rawcode(base[0].upper() + '000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        worker = data[worker]
        if count_fields(worker, 'Builds') >= 11:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Builds', worker.name))

        data[rawcode] = data[base]
        unit = data[rawcode]
        
        unit['Name'] = '"{}"'.format(name)
        unit['Upgrade'] = EMPTY
        unit['Trains'] = EMPTY
        unit['race'] = '"{}"'.format(race)
        unit['campaign'] = Section(worker)['campaign']
        append_rawcode(worker, 'Builds', rawcode)
            

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

        return data[unit.name]

    @database_safe
    def create_unit(self, name, production, base):
        data = self.data
        rawcode = data.new_rawcode(base[0].upper() + '000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data[base] if base in data else {'_parent': f'"{DEFAULTS[base].name}"'}  # make sure exception is raised if base does not exist
        unit = data[rawcode]
        first = production
        production = data[production]

        while count_fields(production, 'Upgrade', 'Trains') >= 12:
            upgrade = Section(production)['Upgrade'][1:-1]
            if upgrade == '' or upgrade == first:
                production = self._create_upgrade(production.name, first)
            else:
                production = data[upgrade]

        unit['Name'] = '"{}"'.format(name)
        unit['race'] = Section(production)['race']
        unit['campaign'] = Section(production)['campaign']
        append_rawcode(production, 'Trains', rawcode)
        return rawcode

    @database_safe
    def create_tower(self, name, isReforged):
        data = self.data
        rawcode = data.new_rawcode('N000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data['n07L'] if isReforged else data['n03D']
        unit = data[rawcode]
        
        unit['Name'] = f'"Tower: {name}"'
        unit['Sellunits'] = EMPTY

    @database_safe
    def create_hero(self, name, propername, tower, race, base):
        data = self.data
        rawcode = data.new_rawcode(base[0].upper() + '000')

        if base[0].lower() == base[0]:
            raise ValueError("Base unit must be a hero!")

        tower = data[tower]
        if count_fields(tower, 'Sellunits') >= 12:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Sellunits', tower.name))

        data[rawcode] = data[base] if base in data else {'_parent': f'"{DEFAULTS[base].name}"'}
        unit = data[rawcode]

        if Section(tower)['campaign'] == '1':
            name = '_HD ' + name
            if propername: 
                propername = '_HD ' + propername

        unit['Name'] = f'"{name}"'
        unit['Propernames'] = f'"{propername}"' if propername else '" "'
        unit['race'] = f'"{race}"'
        unit['campaign'] = '1' if propername else '0'
        
        append_rawcode(tower, 'Sellunits', rawcode)

        return rawcode

    @database_safe
    def create_deco_builder(self, name, isReforged):
        data = self.data
        rawcode = data.new_rawcode('U000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data['u014']
        unit = data[rawcode]

        unit['Name'] = f'"{name}"'
        unit['Builds'] = EMPTY
        unit['campaign'] = '1' if isReforged else '0'

    @database_safe
    def create_decoration(self, name, model, builder, isBuilding, pathTex):
        data = self.data
        rawcode = data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        builder = data[builder]
        if count_fields(builder, 'Builds') >= 11:
            raise IndexError('Adding more units than supported to "{}" field in [{}]'.format('Builds', builder.name))

        data[rawcode] = data['h038'] if not isBuilding else data['h01S']
        unit = data[rawcode]

        unit['Name'] = f'"{name}"'
        unit['Upgrade'] = EMPTY
        unit['file'] = f'"{model}"'.replace('\\', '\\\\').replace('\\\\\\\\', '\\\\')
        unit['campaign'] = Section(builder)['campaign']
        unit['pathTex'] = pathTex if isBuilding else ''
        append_rawcode(builder, 'Builds', rawcode)

    @database_safe
    def create_variation(self, name, model, parent):
        data = self.data
        rawcode = data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]

        data[rawcode] = data[parent]
        unit = data[rawcode]
        parent = Decoration(data[parent])

        index = parent.add_upgrade(rawcode)
        unit['Name'] = f'"{name.format(index=index+1)}"'
        unit['file'] = f'"{model.format(index=index)}"'.replace('\\', '\\\\').replace('\\\\\\\\', '\\\\')

        return rawcode
