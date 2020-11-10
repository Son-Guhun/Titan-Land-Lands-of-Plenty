from PIL import Image, ImageFilter
import os
import pyperclip
import json

root = "..\\.future"
folder = "pathtextures"


def do():
    dirpath = os.path.join(root, folder)
    used = []
    result = []
    
    for filename in os.listdir(dirpath):
        if not os.path.isdir(os.path.join(dirpath, filename)):
            with Image.open(os.path.join(dirpath, filename)) as im:
                im = im.transpose(Image.ROTATE_90)
                
                minI, minJ = im.width, im.height
                maxI = maxJ = 0

                cells = []
                for j in range(im.height):
                    for i in range(im.width):
                        if im.getpixel((i,j))[0] == 255:
                            minI, minJ = min(minI,i), min(minJ,j)
                            maxI, maxJ = max(maxI,i), max(maxJ,j)
                            cells.append((i,j))

                if len(cells) > 0:
                    used.append(filename)
                    width = maxI-minI+1
                    height = maxJ-minJ+1
                    if len(cells) == width*height:
                        result.append('set paths["{}"] = PathingMap.getGeneric({},{})'.format(filename, width, height))
                        # print(filename, width, height)
                    else:
                        result.append("set tiles = LinkedHashSet.create()")
                        for cell in cells:
                            result.append("call tiles.append(PathTile.fromIndices({},{}))".format(*cell))
                        result.append('set paths["{}"] = PathingMap.createWithList({},{}, tiles)'.format(filename, width, height))
                        # print(filename, cells)

    with open('used_pathtexs.json', 'w') as f:
        json.dump(used, f, indent=2)

    pyperclip.copy("\n".join(result))
