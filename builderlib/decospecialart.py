from myconfigparser import MyConfigParser, load_unit_data, get_decorations


def configure_decorations(unit_data, decoration_list):
    for decoration in decoration_list:
        try:
            unit_data[decoration]['Specialart'] = '"{}"'.format(',' + unit_data[decoration]['file'][1:-1])
        except:
            print("Could not find model data for {}.".format(decoration))

def do_everything(file_path):
    f = open(file_path)
    unit_data = load_unit_data(f)
    
    decorations = get_decorations(unit_data)
    configure_decorations(unit_data, decorations)
    
    f = open(file_path, 'w')
    unit_data.write(f)
    
