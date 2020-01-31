from myconfigparser import load_unit_data

to_remove=[
'h1IG',
'h1IB',
'h1IA',
'h1I8',
'h1II',
'h1ID',
'h1IC',
        ]


dataBase = '../development/table/unit.ini'
def do(dataBase=dataBase, to_remove=to_remove):
    with open(dataBase) as f:
        unit_data = load_unit_data(f)

    for unit in (x for x in to_remove if x in unit_data):
        if unit_data[unit]['_parent'][1:-1] == unit:
            for field in unit_data[unit]:
                if field == 'Name':
                    unit_data[unit]['Name'] = unit_data[unit]['Name'].replace('-DEPRECATED', '-REMOVED')
                elif field != '_parent':
                    del unit_data[unit][field]
        else:
            del unit_data[unit]

    with open(dataBase, 'w') as f:
        unit_data.write(f)

    return unit_data
