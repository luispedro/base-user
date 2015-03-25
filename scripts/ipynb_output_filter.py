#! /usr/bin/env python

# Originally from http://stackoverflow.com/questions/18734739/using-ipython-notebooks-under-version-control

import sys
from IPython.nbformat.current import read, write

json_in = read(sys.stdin, 'json')
if 'signature' in json_in.metadata:
    del json_in.metadata['signature']

for sheet in json_in.worksheets:
    for cell in sheet.cells:
        if "outputs" in cell:
            cell.outputs = []

        if "prompt_number" in cell:
            del cell['prompt_number']
            #cell.prompt_number = ''

write(json_in, sys.stdout, 'json')
