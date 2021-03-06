"""
Credits to gohagga for the algorithm.
"""

from myconfigparser import UnitParser, Section, load_unit_data, get_decorations

def get_substrings(string):
    "Returns all possible substrings of a string."
    return [string[i: j] for i in range(len(string)) 
          for j in range(i + 1, len(string) + 1)]
    

def map_names(unit_data, decoration_list):
    """
    Returns a map of (decoration name)->(decoration rawcode) for every decoration in decoration_list
    """
    names = {}
    for decoration in decoration_list:
        data = Section(unit_data[decoration])
        names[data['Name'][1:-1]] = decoration

    return names
    

def do_everything(file_path):
    """
    Opens a file as a ConfigParser and returns the result of map_names() using all decorations found.
    """
    with open(file_path) as f:
        unit_data = load_unit_data(f, parser=UnitParser)
    
    decorations = unit_data.get_primary_decorations(asString=True)
    return map_names(unit_data, decorations)
    

def map_substrings(deco_names):
    """
    Returns a map of (substrings)->(rawcodes), i.e. a map from each substring
    to all units whose name includes that substrings.
    """
    stuff = {}
    for string in deco_names:
        for substring in set(get_substrings(string.lower())):
            if len(substring) <= 5:
                if substring not in stuff:
                    stuff[substring] = [deco_names[string]]
                else:
                    stuff[substring].append(deco_names[string])
    return stuff

def comparator(pair):
    return len(pair[0]), pair[0].lower(), pair[0]

def to_JASS(dict_):
    """
    Returns JASS library code form of map_substrings() result.
    """
    lines = []
    for key,value in sorted(dict_.items(), key=comparator):
        lines.append('set l=Table.create()\n')
        lines.append(f'set d[StringHash("{key}")]=l\n')
        for i,string in enumerate(value):
           lines.append(f"set l[{i}]='{string}'\n")

    return lines

