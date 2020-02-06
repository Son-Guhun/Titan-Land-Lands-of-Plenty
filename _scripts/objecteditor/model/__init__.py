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

            
            
