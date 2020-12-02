"""
This module contains Section classes that represent units. A section class is a class
which wraps a section of a configparser. In w3x2lni, all objects have a "_parent" field
which stores the original object from which they were derived. A Section uses this field
to find the parent section in the DEFAULT configparser, which contains the default values
used by wc3, and wraps that parent section as well.

Whenever there is an attempt to get an item from a Section, if that key does not exist in the
wrapped configparser section, then the equivalent item is returned from the parent section. There
are also specialized Section classes which extend the original class and offer useful method.

Section classes:
    - Section or Unit
    - Production
    - Decoration

Additionally, this file defines the UnitParser class, which inherits from MyConfigParser. This parser
can be passed to the "load_unit_data" function in order to return a parser that contains many utility methods
for working with unit data.
"""

from . import MyConfigParser, load_unit_data
import itertools

# Defaults parser, which is nromally initialized in myconfigparser.py.
DEFAULTS = None

# Fields which may be empty even in the default unit sections.
FIELDS = set(('EditorSuffix', 'Hotkey', 'Builds', 'Trains', 'Upgrade', 'abilList', 'Sellunits', 'Propernames'))

class Section:
    
    def __init__(self, section):
        if '_parent' not in section: print(section.name)
        self._section = section
        self._default = DEFAULTS[section['_parent'][1:-1]]
        # self.name = section.name

    @property
    def name(self):
        return self._section.name
        
    @property
    def parser(self):
        return self._section.parser

    @property
    def tags(self):
        tags =  self['EditorSuffix'][1:-1]
        tags = tags.split('[')
        for tag in tags:
            if tag.endswith(']'):
                yield tag[:-1]

    def list(self, field, wrapper=None):
        strings = self[field][1:-1].split(',')
        if strings[0] == '':
            return []
        
        if wrapper:
            return [wrapper(self._section.parser[s]) for s in strings]
        else:
            return strings

    def is_hero(self):
        return self.name[0].isupper()

    def get_version(self):
        if self.is_hero():
            return 2 if self['Name'][1:-1].startswith('_HD') else 1
        else:
            return 2 if int(self['campaign']) else 1
            

    def isbldg(self):
        return int(self['isbldg'])

    def has_tag(self, tag):
        return (f'[{tag}]' if tag[0] == '[' else tag) in self['EditorSuffix']
        
    def __getitem__(self, i):
        if i in self._section:
                return self._section[i]
        try:
            return self._default[i.lower()]
        except KeyError:
            if i in FIELDS:
                return '""'
            else:
                raise KeyError("Unknown field:", i)
    
    def __setitem__(self, i, value):
        in_defaults = i.lower() in self._default
        if in_defaults and self._default[i.lower()] == value and i in self._section:
            del self._section[i]
        else:
            if value == '""' and not in_defaults:
                if i in self._section:
                    del self._section[i]
            else:
                self._section[i] = value
        
    def __contains__(self, i):
         return i in self._section
        
    def __delitem__(self, i):
        del self._section[i]

Unit = Section

class Production(Section):

    def upgrades(self, asString=False):
        yield self.name if asString else self
        current = self['Upgrade'][1:-1]
        if current != '':
            while current != self.name:
                current = Section(self.parser[current])
                yield current.name if asString else current
                current = current['Upgrade'][1:-1]

    def trained(self, asString=False):
        for prod in self.upgrades():
            for u in prod['Trains'][1:-1].split(','):
                if u != '':
                    yield u if asString else Section(self.parser[u])

            
class Decoration(Section):

    def selectable_only(self):
        return 'A04U' in self['abilList']

    def allow_unselectable(self):
        return not self.selectable_only()

    def upgrades(self, asString=False):
        yield self.name if asString else self
        current = self['Upgrade'][1:-1].split(',')[0]
        if current != '':
            while current != self.name:
                current = Section(self.parser[current])
                yield current.name if asString else current
                current = current['Upgrade'][1:-1].split(',')[0]

    def add_upgrade(self, other):
        upgrades = list(self.upgrades())

        if type(other) == str:
            other = Section(self.parser[other])

        length = len(upgrades)
        if length == 1:
            prev = self
            
            prev['Upgrade'] = f'"{other.name}"'
            other['Upgrade'] = f'"{prev.name}"'
        else:
            prev2 = upgrades[-2]
            prev = upgrades[-1]
            next = self
            next2 = upgrades[1]

            prev['Upgrade'] = f'"{other.name},{prev2.name}"'
            other['Upgrade'] = f'"{next.name},{prev.name}"'
            next['Upgrade'] = f'"{next2.name},{other.name}"'

        return length


class UnitParser(MyConfigParser):

    def sections(self):
            for key in self:
                yield Section(self[key])

    def get_with_tags(self, tags, wrapper=Section):
        if isinstance(tags, str):
            for u in self:
                unit = wrapper(self[u])
                if unit.has_tag(tags):
                    yield unit
        else:
            tags = set(tags)
            for u in self:
                unit = wrapper(self[u])
                if tags.issubset(unit.tags):
                    yield unit

    def get_with_ability(self, ability, asString=False, wrapper=Section):
        for u in self:
            unit = wrapper(self[u])
            if ability in unit['abilList']:
                yield u if asString else unit
    
    def get_decobuilders(self, asString=False, builder_only = False):
        for unit in self.get_with_ability('A00J'):
            if not builder_only or unit['Builds'] != '""':
                yield unit.name if asString else unit

    def get_primary_decorations(self, asString=False):
        for builder in self.get_decobuilders(builder_only=True):
            for decoration in builder.list('Builds'):
                yield decoration if asString else Decoration(self[decoration])

    def get_hero_towers(self):
        for unit in self.sections():
            if unit['Name'].startswith('"Tower: '):
                yield unit

    def get_selectors(self):
        yield from self.get_with_tags("sele", wrapper=Section)

    def get_builders(self):
        yield from itertools.chain(*(u.list('Trains', Section) for u in self.get_selectors()))

    def get_decorations(self, asString=False):
        yield from self.get_with_ability('A0C6', asString=asString, wrapper=Decoration)

    def get_heroes(self):
        yield from itertools.chain(*(unit.list('Sellunits', Section) for unit in self.get_hero_towers()))

    def get_production_bldgs(self):
        yield from self.get_with_tags("prod", wrapper=Production)

    def get_spawners(self):
        yield from self.get_with_tags("spawn", wrapper=Production)

    def get_troops(self):
        yield from itertools.chain(*(unit.trained() for unit in self.get_production_bldgs()))

    def get_civilians(self):
        yield from itertools.chain(*(unit.trained() for unit in self.get_spawners()))
