from myconfigparser import Section

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