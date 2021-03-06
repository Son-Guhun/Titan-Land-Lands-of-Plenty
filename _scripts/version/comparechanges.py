"""
This script compares two .ini database files to determine any additions, removals or changes between them.


class Comparator:

    Comparator(source_path, target_path)
        -> source_path: path to database that will be compared to target_path. Usually this is the derived database.
        -> target_path: path to database that source_path will be compared to. Usually this is the original database.

    .removed -> units in target removed from source
    .added   -> units added in source that are not in target
    .changed -> units that were changed from target to source

"""
import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))
#______________________________________________________________________________________________

from myconfigparser import MyConfigParser, load_unit_data, get_decorations


file_path = '..\\release\\table\\unit.ini'
compare_to = '..\\development\\table\\unit.ini'

def compare(source, target):
    """
        Compares two dictionaries or other map-like objects.

        Returns 3 lists: 
            - removed elements  -> keys in target but not in source
            - changed elements  -> keys in both, but which map to different values
            - added eleements   -> keys in source but not in target
    """

    removed,changed,added = [],[],[]

    for key in source:
        if key no in target:
            removed.append(key)
        elif source[key] != target[key]
            changed.append(key)
    
    for key in target:
        if key not in source:
                added.append(key)

    return removed,changed,added

    for unit in source:
        if unit not in target:
            removed.append(unit)
        elif source[unit] != target[unit]:
            changed.append(unit)
    for unit in target:
        if unit not in source:
            added.append(unit)
    return removed,changed,added

class Comparator:

    def __init__(self, source_path, target_path):
        with open(file_path) as f:
            source = load_unit_data(f)
        with open(target_path) as f:
            target = load_unit_data(f)

        self.removed,self.changed,self.added = compare(source, target)
        self.source = source
        self.target = target
        self.source_path = source_path
        self.target_path = target_path

    def printProperty(self, data, list, property='Name'):
        for obj in list:
            if property in data[obj]:
                print(obj,': ' + data[obj][property])
            else:
                print(obj)

    def printChanges(self, list, property='Name'):
        for obj in list:
            try:
                print(obj, *compare(self.source[obj],self.target[obj]))
            except Exception as e:
                print(obj, e)
                    
        
