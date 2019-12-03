import os
from myconfigparser import MyConfigParser, load_unit_data, get_decorations

to_remove=[
         'h000'
        ,'h007'
        ,'h008'
        ,'h01Y'
        ,'h006'
        ,'h01Z'
        ,'h028'
        ,'h021'
        ,'h026'
        ,'h02A'
        ,'h027'
        ,'h02B'
        ,'h020'
        ,'h025'
        ,'h022'
        ,'h01U'
        ,'h01V'
        ,'h023'
        ,'h030'
        ,'h031'
        ,'h032'
        ,'h036'
        ,'h033'
        ,'h037'
        ,'h0VI'
        ,'h0VJ'
        ,'hkee'
        ,'hcas'
        ,'hgtw'
        ,'hctw'
        ,'hatw'
        ,'ogre'
        ,'ostr'
        ,'ofrt'
        ,'oalt'
        ,'otrb'
        ,'osld'
        ,'ovln'
        ,'ofor'
        ,'owtw'
        ,'nntt'
        ,'h12K'
        ,'o02U'
        ,'o00I'
        ,'ogre'
        ,'h004'
        ,'o00L'
        ,'o00N'
        ,'o00M'
        ,'o01Z'
        ,'u04K'
        ,'h0ZZ'
        ,'u047'
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
