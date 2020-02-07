from myconfigparser import Section, DEFAULTS

template = '{name} [{code}]'
get_string_unit = lambda string: string[-5:-1]
RACES = {
    'Human': 'human',
    'Orc': 'orc',
    'Undead': 'undead',
    'Night Elf': 'nightelf',
    'Naga': 'naga',
    'Creep': 'creeps'
}

races = {
    'Human': ['human'],
    'Orc': ['orc'],
    'Undead': ['undead'],
    'Night Elf': ['nightelf'],
    'Naga': ['naga'],
    'Creep': set(['commoner','creeps','critters','demon','other','unkown'])
}

def filter_listbox(data, window, values, suffix, options):
            search = values['Search'+suffix].lower()
            if not search.startswith('id:'):
                if options.search(search):
                    current = options.search(search)
                else:
                    current = options

                if 'Race'+suffix in values:
                    race = values['Race'+suffix]
                    if race != 'Any':
                        current = [string for string in current if Section(data[get_string_unit(string)])['race'][1:-1] in races[race]]

                if 'Mode'+suffix in values:
                    mode = values['Mode'+suffix]

                    def f(x):
                        u = get_string_unit(x)
                        if u[0].lower() == u[0]:
                            return Section(data[u])['campaign'] == mode
                        else:
                            return mode=='1' if Section(data[u])['Name'][1:-1].startswith('_HD') else mode=='2'

                    if mode != 'Both':
                        mode = '1' if mode == 'Reforged' else '0'
                        current = [string for string in current if f(string)]
            else:
                rawcode = values['Search'+suffix][3:]
                if rawcode in data:
                    current = [template.format(code=rawcode,name=Section(data[rawcode])['Name'][1:-1])]
                elif rawcode in DEFAULTS:
                    current = [template.format(code=rawcode,name=DEFAULTS[rawcode]['name'][1:-1])]
                else:
                    current = []

            window.find_element('Options'+suffix).Update(sorted(current))
