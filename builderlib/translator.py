import subprocess
import os
import json

class Translator:

    def __init__(self, root_folder):
        if root_folder[-1] != os.path.sep:
            root_folder = root_folder + os.path.sep

        self.root_folder = os.path.abspath(root_folder)


    def translate(self):
        pass

    def parse(self):
        return json.loads(''.join(open(self.root_folder + 'doodads.json').readlines()))

    def generateJass(self):
        doodads = self.parse()
        types = set()

        output = []
        for doodad in doodads:
            output.append('call CreateDoodadEffect(\'{type}\',{xyz},{angle},{scaleXYZ})'.format(type=doodad['type'],
                                                                                            xyz=','.join([str(x) for x in doodad['position']]),
                                                                                            angle=doodad['angle'],
                                                                                            scaleXYZ=','.join([str(x) for x in doodad['scale']]),
                                                                                     ))
        return output
    
