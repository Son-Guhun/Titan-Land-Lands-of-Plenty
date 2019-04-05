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


def build_config():
    if not os.path.exists('config.ini'):
        with open('config.ini','w') as f:
            pass

from shutil import copyfile


def copy():
    copyfile(DEVELOPMENT, RELEASE)


def build(which):
    subprocess.Popen([p['paths']['w2l'],'obj',os.path.abspath(which)])

def commit(which):
    subprocess.Popen([p['paths']['w2l'],'lni',os.path.abspath(which)])

def optimize(which):
    subprocess.Popen([p['paths']['w2l'],'slk',os.path.abspath(which)])



def test_full():
    optimize(DEVELOPMENT)
    test('slk')
    
