import configparser

p = configparser.ConfigParser()

p.read('config.ini')
import subprocess
import os

def open_with_editor():
    subprocess.Popen([p['paths']['worldedit'],'-loadfile',os.path.abspath('development.w3x')])


def test(version=''):
    subprocess.Popen([p['paths']['war3'],'-loadfile',os.path.abspath('development{}.w3x'.format('_' + version if version else ''))])


DEVELOPMENT = 'development.w3x'
RELEASE = 'release.w3x'

def convert(which, type):
    subprocess.Popen([p['paths']['war3'],'-loadfile',os.path.abspath(which)])


config_values = {
    'paths': {'w2l':'',
              'war3':'',
              'worldedit': ''}
    }
def generate_config(path='config.ini'):
    if not os.path.exists(path):
        writer = configparser.ConfigParser()
        writer.read_dict(config_values)
        with open(path,'w') as f:
            writer.write(f)

from shutil import copyfile


def copy():
    copyfile(DEVELOPMENT, RELEASE)


def build(which):
    """Creates an OBJ from an LNI map"""
    subprocess.Popen([p['paths']['w2l'],'obj',os.path.abspath(which)])

def commit(which):
    """Creates an LNI from an OBJ map"""
    subprocess.Popen([p['paths']['w2l'],'lni',os.path.abspath(which)])

def optimize(which):
    """Create an SLK from an OBJ"""
    subprocess.Popen([p['paths']['w2l'],'slk',os.path.abspath(which)])


import shutil
def push(dirs = ['table', 'trigger', 'w3x2lni']):
    release= 'release/'
    development = 'development/'
    for directory in dirs:
        shutil.rmtree(release+directory)
        shutil.copytree(development+directory, release+directory)

def push_all():
    transfer(['map', 'table', 'trigger', 'w3x2lni'])

def pull():
    pass
    # if path does not exist => create the folder
    # copytree for each one of these: map, table, trigger, w3xlni

def test_full():
    optimize(DEVELOPMENT)
    test('slk')
    
import webbrowser

def show_gui(file):
    webbrowser.open(os.path.dirname(p['paths'][file]))


import types
# __doc__ = '\n================\n'.join([(f).__doc__ for f in globals().values() if type(f) == types.FunctionType])

def helpme():
    for f in [(f) for f in globals().values() if type(f) == types.FunctionType]:
        help(f)
        print("==============================")


def ls():
    for f in [(f) for f in globals().values() if type(f) == types.FunctionType]:
        print (str(f).split()[1])

print('For help type ls()')
