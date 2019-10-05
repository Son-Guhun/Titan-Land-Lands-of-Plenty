import configparser
import subprocess
import os
import shutil
import webbrowser
import builderlib

try:
    p = configparser.ConfigParser()
    p.read('config.ini')
except:
    print("Unable to load configuration file.")


DEVELOPMEN_LNI = 'development'
RELEASE_LNI = 'release'
DEVELOPMENT = 'development.w3x'
RELEASE = 'release.w3x'
DEVELOPMENT_SLK = 'development_slk.w3x'
RELEASE_SLK = 'release_slk.w3x'


config_values = \
{
    'paths': {'w2l':'',
            'war3':'',
            'worldedit': ''},
    # Accept any number of programs, and executes them in order
    'jass-preprocessors': { 
    },
    'obj-postprocessors': {

    },
    'slk-postprocessors': {

    },
}

def test(version='',build='development'):
    """Opens a .w3x map with Warcraft III."""
    subprocess.Popen([p['paths']['war3'],'-loadfile',os.path.abspath(build+'{}.w3x'.format('_' + version if version else ''))])
    
def test_map(map=DEVELOPMENT_SLK):
    subprocess.Popen([p['paths']['war3'],'-loadfile',os.path.abspath(map)])

def open_with_editor(file=DEVELOPMENT):
    subprocess.Popen([p['paths']['worldedit'],'-loadfile',os.path.abspath(file)])

def generate_config(path='config.ini'):
    if not os.path.exists(path):
        writer = configparser.ConfigParser()
        writer.read_dict(config_values)
    else:
        writer = configparser.ConfigParser()
        writer.read_dict(config_values)
        writer.read(path)
    with open(path,'w') as f:
        writer.write(f)

def build(which):
    """Creates an OBJ from an LNI map"""
    return subprocess.Popen([p['paths']['w2l'],'obj',os.path.abspath(which)]).wait()

def commit(which):
    """Creates an LNI from an OBJ map"""
    return subprocess.Popen([p['paths']['w2l'],'lni',os.path.abspath(which)]).wait()

def optimize(which):
    """Create an SLK map from an OBJ or LNI map"""
    return subprocess.Popen([p['paths']['w2l'],'slk',os.path.abspath(which)]).wait()


def push(dirs = ['table', 'trigger', 'w3x2lni']):
    """Copies all specified directories from the development folder to the release folder."""
    release= 'release/'
    development = 'development/'
    for directory in dirs:
        shutil.rmtree(release+directory)
        shutil.copytree(development+directory, release+directory)

def push_all():
    """As push, but includes the map directory, which contains many binary files."""
    push(['map', 'table', 'trigger', 'w3x2lni'])

def pull(dirs = ['map','table', 'trigger', 'w3x2lni']):
    """Copies all specified directories from the release folder to the developlment folder."""
    release= 'release/'
    development = 'development/'

    if not os.path.exists(development):
        os.mkdir(development)

    if not os.path.exists('development/.w3x'):
        shutil.copy('release/.w3x', 'development/.w3x')

    for directory in dirs:
        if os.path.exists(development+directory):
            shutil.rmtree(development+directory)
        shutil.copytree(release+directory,development+directory)

def test_full(build=DEVELOPMENT):
    """Optimizes an OBJ map and then opens the generated SLK in WC3."""
    optimize(build)
    test('slk',build[:build.rfind('.w3x')])

def open_in_explorer(file):
    """Opens a file in the Windows explorer (or equivalent)."""
    webbrowser.open(os.path.dirname(p['paths'][file]))

def helpme():
    """Prints all available user-defined functions and their doc strings"""
    for f in builderlib.get_user_functions(globals()):
        help(f)
        print("==============================")


def ls():
    """Prints all avaiable user-defined functions."""
    for f in builderlib.get_user_functions(globals()):
        print (str(f).split()[1])

print('For help type ls()')
