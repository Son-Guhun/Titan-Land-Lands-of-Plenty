"""

Map variants:
    DEVEL         -> Does not contain most unit object data. Contains only necessary pre-placed doodads. Saves the fastest in the Editor.
                  -> Used when editing script files.
                  -> Loads quickly in WC3. Great for testing script changes.

    DEVELOPMENT   -> Does not contain imports. Saves considerable faster than RELEASE in the World Editor.
                  -> Used when editing object data.
                  -> For creating new object data, the objecteditor python package is more convenient to use.

    RELEASE       -> Contains entire map contents.
                  -> Generally isn't opened in the editor.


Constants that refer to file paths for different map types:

    LNI => folder maps
        'release', 'development', 'devel'
    
    OBJ => normal maps
        RELEASE, DEVELOPMENT, DEVEL

    SLK => slk-optimized maps
        RELEASE_SLK, DEVELOPMENT_SLK, DEVEL_SLK 


Commands:

    open_with_editor()                                         => Opens DEVELOPMENT in the World Editor.
    open_with_editor(DEVEL)                                    => Opens DEVEL in the World Editor.

    .. Converting between map types:
    build('release'), build('development'), build('devel')     => Converts an LNI map to an OBJ map.
    commit(DEVELOPMENT), commit(DEVEL)                         => Converts an OBJ map to an LNI map.

    .. Pushing changes upstream across variants:
    push_all()                                                 => Pushes files in 'development' to 'release'
    push_devel()                                               => Pushes files in 'devel' to 'development'
    push_devel('release')                                      => Pushes files in 'devel' to 'release'
    
    .. Pulling changes downstream:
    pull()                                                     => Pulls changes from 'release' to 'development'. Creates folders if they don't exist.
    make_devel()                                               => Pulls changes from 'development' to 'devel'. Creates folders if they don't exist.

    .. Testing:
    test_map(RELEASE), test_map(DEVELOPMENT), test_map(DEVEL)  => Opens an SLK or OBJ map in WC3.
    test_devel()                                               => Executes commit(DEVEL)->push_devel()->build('development')->test_map(DEVELOPMENT)
    test_devel('release')                                      => Same as test_devel, but for 'release' equivalents.


Setting up:

    Initial setup, then work on the map in the World Editor:
            => run this builder.py script in an interactive Python console.
            - generate_config()
            => Open the config.ini file created in root folder and put in the correct values. Check the guide below.
            - read_config()
            - pull()
            - build('development')
            - make_devel()
            - build('devel')
            - open_with_editor() OR open_with_editor(DEVEL)

    config.ini file fields:

        paths:
            w2l: path to w2l.exe (in w3x2lni folder)
            war3: path to a classic wc3 version executable (optional) 
            war3r: path to the Warcraft Reforged executable (not launcher)
            worldedit: path to world editor used (usually SharpCraft editor running wc3 patch 1.29.2)

        jass-preprocessors: ignore
        obj-postprocessors: ignore
        slk-postprocessors: ignore


Command Examples:

    Working with DEVEL in Editor. Send all changes to release folder:
        - commit(DEVEL)
        - push_devel('release')
        => Changes will now show up in git.

    Working with DEVELOPMENT in Editor. Send all changes to release folder:
        - commit()
        - push_all()

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


DEVELOPMEN_LNI = 'development'
RELEASE_LNI = 'release'
DEVEL_LNI = 'devel'
DEVELOPMENT = 'development.w3x'
RELEASE = 'release.w3x'
DEVEL = 'devel.w3x'
DEVELOPMENT_SLK = 'development_slk.w3x'
RELEASE_SLK = 'release_slk.w3x'
DEVEL_SLK = 'devel_slk.w3x'

p = None  # hold read config values

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
    """Switches between Reforged and Classic exectuables"""
    temp = p['paths']['war3']
    p['paths']['war3'] = p['paths']['war3r']
    p['paths']['war3r'] = temp

def test_map(map=DEVELOPMENT_SLK, hd=None):
    args =[]
    if hd is not None:
        args.extend(('-hd', '1' if hd else '0'))

    subprocess.Popen([p['paths']['war3'],
                      '-loadfile', os.path.abspath(map),
                      '-launch']
                     + args)

def test(version='', build='development', **kwargs):
    """Opens a .w3x map with Warcraft III."""
    test_map(os.path.abspath(build+'{}.w3x'.format('_' + version if version else '')), **kwargs)
    
def test_devel(target='development', **kwargs):
    commit(DEVEL)
    push_devel(target)
    build(target)
    test_map(target+'.w3x', **kwargs)

def test_full(build=DEVELOPMENT, **kwargs):
    """Optimizes an OBJ map and then opens the generated SLK in WC3."""
    optimize(build)
    test('slk', build[:build.rfind('.w3x')], **kwargs)

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

def read_config(path='config.ini'):
    global p
    try:
        p = configparser.ConfigParser()
        p.read(path)
    except:
        print("Unable to load configuration file.")

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
    shutil.copyfile('_scripts/devel_doodad_data.doo', 'devel/map/war3map.doo')  # script file

def copy_file_if_exists(source, target):
    if os.path.exists(source):
        shutil.copyfile(source, target)

def push_devel(target='development'):
    # Copy script-related map files
    copy_file_if_exists('devel/map/war3map.j', target+'/map/war3map.j')      # script file
    copy_file_if_exists('devel/map/war3map.w3s', target+'/map/war3map.w3s')  # sound defs file
    copy_file_if_exists('devel/map/war3map.w3r', target+'/map/war3map.w3r')  # rect defs file

    push(release=target+'/', development='devel/', dirs=['trigger'])

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
read_config()
switch()  # use WC3 Reforged by default
