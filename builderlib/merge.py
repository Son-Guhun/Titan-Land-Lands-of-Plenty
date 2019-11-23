from myconfigparser import MyConfigParser, load_unit_data, get_decorations

def merge(source, data, new):

    # These fields reference other units, so they have to be updated when generating new rawcodes.
    fields = 'Upgrade', 'Builds', 'Trains', 'Sellunits'
    
    equivalents = {}
    for unit in new:
        rawcode = data.new_rawcode(unit[0].upper() + '000')
        if unit[0].upper() != unit[0]:
                rawcode = rawcode[0].lower() + rawcode[1:]

                
        equivalents[rawcode] = unit
        equivalents[unit] = rawcode
        data[rawcode] = source[unit]

    for unit in new:
        section = data[equivalents[unit]]
        for field in (x for x in fields if x in section):
            value = section[field]
            
            for u in new:
                value = value.replace(u, equivalents[u])

            section[field] = value

source_path = '../development/table/unit.ini'
target_path = '../.future/development3/table/unit.ini'
new = []
# new = ['h1DJ', 'h1DK', 'h1DL', 'h1DM', 'h1DN', 'h1DO', 'h1DP', 'h1DQ', 'h1DR', 'h1DS', 'h1DT', 'h1DU', 'h1DV', 'h1DW', 'h1DX', 'h1DY', 'h1DZ', 'h1E0', 'h1E1', 'h1E2', 'h1E3', 'h1E4', 'h1E5', 'h1E6', 'h1E7', 'h1E8', 'h1E9', 'h1EA', 'h1EB', 'h1EC', 'h1ED', 'h1EE', 'h1EF', 'h1EG', 'u060', 'u061', 'u062']
def do(source_path=source_path, target_path=target_path, new=new):
    with open(target_path) as f:
        target = load_unit_data(f)

    with open(source_path) as f:
        source = load_unit_data(f)

    merge(source, target, new)

    with open(target_path, 'w') as f:
        data.write(f)
