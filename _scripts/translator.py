"""Translates a .json of doodads into JASS code that generates equivalent DoodadEffects."""
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
        i = 0
        j = 1

        output = []
        output.append('library DoodadEffects{} initializer Init\n'.format(j))
        output.append('private function Init takes nothing returns nothing\n')
        for doodad in doodads:
            output.append('    call CreateDoodadEffect(\'{type}\',{var},{xyz},{angle},{scaleXYZ})\n'.format(type=doodad['type'],
                                                                                                            var = doodad['variation'],
                                                                                                            xyz=','.join([str(x) for x in doodad['position']]),
                                                                                                            angle=doodad['angle'],
                                                                                                            scaleXYZ=','.join([str(x) for x in doodad['scale']]),
                                                                                                     ))
            i += 1
            if i > j*5000:
                j += 1
                output.append('endfunction\n')
                output.append('endlibrary\n')
                output.append('library DoodadEffects{} initializer Init requires DoodadEffects{}\n'.format(j, j-1))
                output.append('private function Init takes nothing returns nothing\n')

        if output[-1] != 'endlibrary\n':
            output.append('endfunction\n')
            output.append('endlibrary\n')
        return output
    
