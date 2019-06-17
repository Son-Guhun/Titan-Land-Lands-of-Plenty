import os
from myconfigparser import MyConfigParser, load_unit_data, get_decorations

def get_relative_path(full_path): 
    string = 'resource' + os.path.sep
    index = full_path.find(string)
    path = full_path[index+len(string):]

    path = path.replace("{sep}_unused{sep}".format(sep=os.path.sep), os.path.sep)
    path = path.replace("{sep}_todo{sep}".format(sep=os.path.sep), os.path.sep)
    return path

modelsFolder = "..\\release\\resource\\_unoptmized\\Decorations\\_StoneAndSword\\Manor"
dataBase = "..\\development\\table\\unit.ini"



def get_models_in_dir(mypath):
    contents = os.listdir(mypath)
    onlyfiles = [f for f in contents if os.path.isfile(os.path.join(mypath,f))]


    def ends_in(string, end):
        return string[-len(end):] == end

    onlymdx = [f for f in onlyfiles if ends_in(f.lower(),".mdx") and not ends_in(f.lower(), "_portrait.mdx")]

    return onlymdx

# print('{}: {}'.format(rawcode, unit_data[rawcode]['Name']))

def do(dataBase, modelsFolder, category):
    filenames = get_models_in_dir(modelsFolder)
    paths = [get_relative_path(os.path.join(modelsFolder, f)) for f in filenames]

    with open(dataBase) as f:
        unit_data = load_unit_data(f)

    for model,path in zip(filenames,paths):
        rawcode = unit_data.new_rawcode('H000')
        rawcode = rawcode[0].lower() + rawcode[1:]
        
        unit_data[rawcode] = unit_data['h038']
        unit_data[rawcode]['file'] = '"{}"'.format(path).replace("\\","\\\\")
        unit_data[rawcode]['Name'] = '"{} {}"'.format(category, model)

    with open(dataBase, 'w') as f:
        unit_data.write(f)

    return unit_data

