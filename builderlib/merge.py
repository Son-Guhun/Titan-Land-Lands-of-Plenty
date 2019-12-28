from myconfigparser import MyConfigParser, load_unit_data, get_decorations

# TODO: Iterate over all units in source database and see which units that are not mentioned in new list reference a unit from the new list (add reference in the target database)


def merge(source, data, new, changed):

    # These fields reference other units, so they have to be updated when generating new rawcodes.
    fields = 'Upgrade', 'Builds', 'Trains', 'Sellunits'
    
    equivalents = {}
    for unit in new:
        rawcode = data.new_rawcode(unit[0].upper() + '000')
        if unit[0].upper() != unit[0]:
                rawcode = rawcode[0].lower() + rawcode[1:]

        # print(rawcode)
        # equivalents[rawcode] = unit
        equivalents[unit] = rawcode
        data[rawcode] = source[unit]
    
    for unit in changed:
        data[unit] = source[unit]

    for unit in [equivalents[u] for u in new]+changed:
        section = data[unit]
        for field in (x for x in fields if x in section):
            value = section[field][1:-1]

##            if unit == 'e002':
##                for u in new:
##                    if u in value:

            asList = value.split(',')
            for i,u in enumerate(asList):
                if u in equivalents:
                    print(data[equivalents[u]]['Name'])
                    print(source[u]['Name'])
                    asList[i] = equivalents[u]
                    
            # for u in new:
            #     value = value.replace(u, equivalents[u])

            section[field] = '"{}"'.format(','.join(asList))

source_path = '..\\.future\\New\\Development4\\table\\unit.ini'
target_path = '../release/table/unit.ini'
new = []
changed = []
# new = ['h1DJ', 'h1DK', 'h1DL', 'h1DM', 'h1DN', 'h1DO', 'h1DP', 'h1DQ', 'h1DR', 'h1DS', 'h1DT', 'h1DU', 'h1DV', 'h1DW', 'h1DX', 'h1DY', 'h1DZ', 'h1E0', 'h1E1', 'h1E2', 'h1E3', 'h1E4', 'h1E5', 'h1E6', 'h1E7', 'h1E8', 'h1E9', 'h1EA', 'h1EB', 'h1EC', 'h1ED', 'h1EE', 'h1EF', 'h1EG', 'u060', 'u061', 'u062']

def do(source_path=source_path, target_path=target_path, new=new, changed=changed):
    with open(target_path) as f:
        target = load_unit_data(f)

    with open(source_path) as f:
        source = load_unit_data(f)

    merge(source, target, new, changed)

    with open(target_path, 'w') as f:
        target.write(f)
