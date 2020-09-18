"""This script iterates over all decorations in a .ini database and set their Specialart field
to the format expected by the SpecialEffect system.
"""
try:
    from myconfigparser import UnitParser, load_unit_data
except:
    from .myconfigparser import UnitParser, load_unit_data

dataBase = '../devel/table/unit.ini'

ignored = set([
    'e001', # Race Selector
    'H00V', # Cosmosis
    'H00U', # Cosmosis
    'H00S', # Creator
    'n000', # Give Unit To
    'udr0', # Rect Generator
    'udr1', # Rect Generator Dummy
    'H0QU',
    'nmgv', # Magic Vault
    'n02W', # Ring Vault
    'n02V', # Vault of Relics
    'n02X', # Vault of Tomes
    'n02R', # Titanic Teleportation Solutions
    ])

conditions = [
    lambda u: u.name in ignored,
    lambda u: u["Name"][1:-1].startswith("Tower: "),
    lambda u: u["Name"][1:-1].startswith("-Power: "),
    lambda u: "[sele]" in u["EditorSuffix"],
    # lambda u: unit["Builds"] != '""',
    ]

def do(file_path, dataBase=dataBase):
    global ignored
    with open(file_path) as f:
        data = load_unit_data(f, parser=UnitParser)

    ignored = ignored.union(set(data.get_decobuilders(asString=True)))
    for unit in [s for s in data.sections()]:
        if not any([c(unit) for c in conditions]):
            del data[unit.name]
            
    with open(dataBase, 'w') as f:
        data.write(f)
    



def old():
    flagged = []
    for decoration in data.get_decorations(asString=True):
        if not decoration.startswith('udr'):
            flagged.append(decoration)

    for u in flagged:
        del data[u]
