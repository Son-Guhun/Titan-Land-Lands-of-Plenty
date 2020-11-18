"""


Map variants:
    DEVEL         -> Does not contain most unit object data. Contains only necessary pre-placed doodads. Saves the fastest in the Editor.
                  -> Used when editing script files.

    DEVELOPMENT   -> Does not contain imports. Saves considerable faster than RELEASE in the World Editor.
                  -> Used when editing object data.
                  -> For creating new object data, the objecteditor python package is more convenient to use.

    RELEASE       -> Contains entire map contents.
                  -> Generally isn't opened in the editor.

"""
import configparser
import subprocess
import os
import shutil
import webbrowser
import types
from _scripts import makedevel

def get_user_functions(table):
    """An iterator that returns all user-defined functions in the global namespace."""
    for f in [(f) for f in table.values() if type(f) == types.FunctionType]:
        yield f


try:
    p = configparser.ConfigParser()
    p.read('config.ini')
except:
    print("Unable to load configuration file.")


DEVELOPMEN_LNI = 'development'
RELEASE_LNI = 'release'
DEVEL_LNI = 'devel'
DEVELOPMENT = 'development.w3x'
RELEASE = 'release.w3x'
DEVEL = 'devel.w3x'
DEVELOPMENT_SLK = 'development_slk.w3x'
RELEASE_SLK = 'release_slk.w3x'
DEVEL_SLK = 'devel_slk.w3x'


config_values = \
{
    'paths': {'w2l':'',
            'war3':'',
            'war3r':'',
            'worldedit': ''},
    # Accept any number of programs, and executes them in order
    'jass-preprocessors': { 
    },
    'obj-postprocessors': {

    },
    'slk-postprocessors': {

    },
}

def switch():
    temp = p['paths']['war3']
    p['paths']['war3'] = p['paths']['war3r']
    p['paths']['war3r'] = temp

def test(version='',build='development'):
    """Opens a .w3x map with Warcraft III."""
    subprocess.Popen([p['paths']['war3'],'-loadfile',os.path.abspath(build+'{}.w3x'.format('_' + version if version else '')),'-launch'])
    
def test_map(map=DEVELOPMENT_SLK):
    subprocess.Popen([p['paths']['war3'], '-loadfile',os.path.abspath(map),'-launch'])

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


def push(dirs = ['table', 'trigger', 'w3x2lni'], release='release/', development='development/'):
    """Copies all specified directories from the development folder to the release folder."""
    for directory in dirs:
        if os.path.exists(release+directory):
            shutil.rmtree(release+directory)
        shutil.copytree(development+directory, release+directory)

def push_all():
    """As push, but includes the map directory, which contains many binary files."""
    push(['map', 'table', 'trigger', 'w3x2lni'])

def pull(dirs = ['map','table', 'trigger', 'w3x2lni'], release='release/', development='development/'):
    """Copies all specified directories from the release folder to the developlment folder."""

    if not os.path.exists(development):
        os.mkdir(development)

    if not os.path.exists(os.path.join(development, '.w3x')):
        shutil.copy(os.path.join(release, '.w3x'), os.path.join(development, '.w3x'))

    for directory in dirs:
        if os.path.exists(development+directory):
            shutil.rmtree(development+directory)
        shutil.copytree(release+directory,development+directory)


def make_devel():
    pull(release='development/', development='devel/', dirs=['scripts', 'map','table', 'trigger', 'w3x2lni'])
    makedevel.do('development/table/unit.ini', 'devel/table/unit.ini')

def push_devel(target='development'):
    # Copy script-related map files
    shutil.copyfile('devel/map/war3map.j', target+'/map/war3map.j')  # script file
    shutil.copyfile('devel/map/war3map.s', target+'/map/war3map.s')  # sound defs file
    shutil.copyfile('devel/map/war3map.r', target+'/map/war3map.r')  # rect defs file

    push(release=target+'/', development='devel/', dirs=['trigger'])

def test_devel(target='development'):
    commit(DEVEL)
    push_devel(target)
    build(target)
    test_map(target+'.w3x')

def test_full(build=DEVELOPMENT):
    """Optimizes an OBJ map and then opens the generated SLK in WC3."""
    optimize(build)
    test('slk',build[:build.rfind('.w3x')])

def open_in_explorer(file):
    """Opens a file in the Windows explorer (or equivalent)."""
    webbrowser.open(os.path.dirname(p['paths'][file]))

def helpme():
    """Prints all available user-defined functions and their doc strings"""
    for f in get_user_functions(globals()):
        help(f)
        print("==============================")


def ls():
    """Prints all avaiable user-defined functions."""
    for f in get_user_functions(globals()):
        print (str(f).split()[1])

print('For help type ls()')
