"""This script takes a list of lists of units in a .ini database and creates an "upgrade chain" from them.

Example:
['h111','u000','o123] => h111 will upgrade to u000 which will upgrade to o123 which will upgrade to h111.
"""
from myconfigparser import MyConfigParser, load_unit_data, get_decorations
import s2id

dataBase = "..\\development\\table\\unit.ini"

def rawcode_range(*args):
    """Returns a rawcode range with the first letter in lower case for each rawcode."""
    return [unit[0].lower() + unit[1:] for unit in s2id.rawcode_range(*args)]

upgrades = [
    rawcode_range('H1CA',4),
    rawcode_range('H1CE',2),
    rawcode_range('H1CG',4),
    rawcode_range('H1CK',5),

    rawcode_range('H1BV',4),
    rawcode_range('H1BZ',2),
    rawcode_range('H1C1',4),
    rawcode_range('H1C5',5),
    
    rawcode_range('H1CP',4),
    rawcode_range('H1CT',2),
    rawcode_range('H1CV',4),
    rawcode_range('H1CZ',5),

    rawcode_range('H1D4',4),
    rawcode_range('H1D8',2),
    rawcode_range('H1DA',4),
    rawcode_range('H1DE',5),


    ]

# print('{}: {}'.format(rawcode, unit_data[rawcode]['Name']))

def do(dataBase, upgrade_lists):
    
    with open(dataBase) as f:
        data = load_unit_data(f)

    for sequence in upgrade_lists:
        length = len(sequence)
        for i,unit in enumerate(sequence):
            data[unit]['Upgrade'] = '"{}"'.format(sequence[(i+1)%length])

    with open(dataBase, 'w') as f:
        data.write(f)

