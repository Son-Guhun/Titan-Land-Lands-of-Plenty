# -*- coding: utf-8 -*-
"""
This script is used to copy the path of assets in the resource folder of an LNI
map to the clipboard. Simply drag the file to the batch file in order to copy.
The path will include everything past "resource/", which means it will be the
path in the MPQ.
"""
import sys
import os
import pyperclip

path = sys.argv[1]

path = os.path.abspath(path)
res = 'resource'+os.path.sep
path = path[path.find(res)+len(res):]

pyperclip.copy(path)
