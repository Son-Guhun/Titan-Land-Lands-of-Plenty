"""

Learn more about pathing maps: https://world-editor-tutorials.thehelper.net/pathmaps.php
"""

import os
import sys
sys.path.insert(1, os.path.join(sys.path[0], '..'))

from PIL import Image, ImageFilter
from itertools import product
import pyperclip
import json

root = "..\\..\\.future"
folder = "pathtextures"

GENERIC_TEMPLATE = 'set paths["{}"] = PathingMap.getGeneric({},{})'

ADVANCED_HEADER      = 'set tiles = LinkedHashSet.create()'
APPEND_TILE_TEMPLATE = 'call tiles.append(PathTile.fromIndices({},{}))'
ADVANCED_TEMPLATE    = 'set paths["{}"] = PathingMap.createWithList({},{}, tiles)'

pixel_is_unwalkable  = lambda im, pixel: im.getpixel(pixel)[0] == 255
pixel_is_unflyable   = lambda im, pixel: im.getpixel(pixel)[1] == 255
pixel_is_unbuildable = lambda im, pixel: im.getpixel(pixel)[2] == 255

def do():
    dirpath = os.path.join(root, folder)
    used = []
    result = ['//! textmacro InitializePathingsMapFromFiles']

    def read_image(im, filename):
        itr = product(range(im.width), range(im.height))
        cells = [pair for pair in itr if pixel_is_unwalkable(im, pair)]

        if cells:
            used.append(filename)
            
            i,j = (list(coords) for coords in zip(*cells))
            width  = max(i) - min(i) + 1
            height = max(j) - min(j) + 1
            
            if len(cells) == width*height:
                result.append(GENERIC_TEMPLATE.format(filename, width, height))
                
            else:
                result.append(ADVANCED_HEADER)
                result.extend(APPEND_TILE_TEMPLATE.format(*c) for c in cells)
                result.append(ADVANCED_TEMPLATE.format(filename, im.width, im.height))

    def recursive(dirpath, dirname=''):
        for filename in os.listdir(dirpath):
            filepath = os.path.join(dirpath, filename)
            relpath  = os.path.join(dirname, filename)
            
            if os.path.isdir(filepath):
                recursive(filepath, dirname=relpath)
            else:
                with Image.open(filepath) as im:
                    # im = im.transpose(Image.ROTATE_90)
                    read_image(im, relpath.replace('\\', '\\\\').lower())

    recursive(dirpath)

    with open('used_pathtexs.json', 'w') as f:
        json.dump(used, f, indent=2)

    result.append('//! endtextmacro')
    pyperclip.copy("\n".join(result))
