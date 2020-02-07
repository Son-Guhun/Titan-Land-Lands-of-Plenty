def get_substrings(string):
    "Returns all possible substrings of a string."
    return [string[i: j] for i in range(len(string)) 
          for j in range(i + 1, len(string) + 1)]

def map_substrings(deco_names):
    """
    Returns a map of (substrings)->(rawcodes), i.e. a map from each substring
    to all units whose name includes that substrings.
    """
    stuff = {}
    for string in deco_names:
        for substring in set(get_substrings(string.lower())):
            if substring not in stuff:
                stuff[substring] = [string]
            else:
                stuff[substring].append(string)
    return stuff

def add_to_map(map, string):
    for substring in set(get_substrings(string.lower())):
            if substring not in map:
                map[substring] = [string]
            else:
                map[substring].append(string)
