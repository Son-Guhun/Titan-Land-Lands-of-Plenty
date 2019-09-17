from myconfigparser import MyConfigParser, load_unit_data, get_decorations


def configure_decorations(unit_data, decoration_list):
    for decoration in decoration_list:
        data = unit_data[decoration]
        try:
            data['Specialart'] = '"{}"'.format(',' + data['file'][1:-1])
        except:
            print("Could not find model data for {}.".format(decoration))
        data['elevPts'] = '0'
        data['elevRad'] = '0.00'

def do_everything(file_path):
    f = open(file_path)
    unit_data = load_unit_data(f)
    
    decorations = get_decorations(unit_data)
    configure_decorations(unit_data, decorations)
    
    f = open(file_path, 'w')
    unit_data.write(f)
    
