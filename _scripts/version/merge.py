"""
This script is used for merging an object dataset into another. It facilitates multiple people working on object data at the same time.

Requirements:
    - 3 files:
        - ORIGNAL  -> An older official version of the dataset, from which FORK was created.
        - FORK     -> A dataset based on ORIGINAL, which was worked on separately from MAIN.
        - MAIN     -> The current official version of the dataset. As such, it was also created from ORIGINAL.

Step-by-step:
    1. Use comparechanges.py:
        a. Compare FORK with ORIGINAL to determine which objects were added or changed in FORK.
        b. Compare MAIN with ORIGINAL to determine which objects were changed.
        c. Take note of conflicts with changed objects in FORK and MAIN.
        d. Compile CHANGED: a list of changed objects from FORK which will overwrite the objects in MAIN.
        c. Compile NEW: a list of new objects from FORK which will be added to MAIN.
    2. Use this script:
        a. call the do function, using the following arguments:
            -> source_path = path to .ini file that holds FORK
            -> target_path = path to .ini file that holds MAIN
            -> new = NEW
            -> changed = CHANGED
    3. Solve conflicts:
        a. If any conflicts were found in step 1.c, then they must be solved after performing the merge operation.
"""
import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))
#______________________________________________________________________________________________

from myconfigparser import MyConfigParser, load_unit_data, get_decorations

# TODO: Iterate over all units in source database and see which units that are not mentioned in new list reference a unit from the new list (add reference in the target database)
    # Basically, this means for example: if deco builder X builds decoration Y in the FORK file, then it will build the equivalent decoraiton Y' in the MAIN file, even if it is not in the changed list.

# These fields reference other units, so they have to be updated when generating new rawcodes.
def replace_equivalents(data, objects, equivalents, fields=('Upgrade', 'Builds', 'Trains', 'Sellunits')):
    for unit in objects:
        section = data[unit]
        for field in (f for f in fields if f in section):
            value = section[field][1:-1]

            asList = value.split(',')
            for i,u in enumerate(asList):
                if u in equivalents:
                    asList[i] = equivalents[u]


            section[field] = '"{}"'.format(','.join(asList))


def create_new_objects(data, new):
    """
    Creates a new entry in dataBase for each object in new, using a new rawcode.

    Returns a dictonary which maps:
        old_rawcodes -> new_rawcodes
    """
    equivalents = {}

    for unit in new:
        rawcode = data.new_rawcode(unit[0].upper() + '000')
        if unit[0].upper() != unit[0]:
                rawcode = rawcode[0].lower() + rawcode[1:]

        equivalents[unit] = rawcode
        data[rawcode] = source[unit]

    return equivalents
    

def merge(source, data, new, changed):    
    """
    Merges source dataset into data dataset.
    """

    equivalents = create_new_objects(data, new)
    
    for unit in changed:
        data[unit] = source[unit]

    replace_equivalents(data, list(equivalents.values())+changed, equivalents)
    

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
