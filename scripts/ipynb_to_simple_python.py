#! /usr/bin/env python

import sys
from IPython.nbformat.current import read
with open('/tmp/log.txt', 'w') as log:
    log.write("Called with {}.\n".format(sys.argv))

if len(sys.argv) != 2:
    sys.stderr.write("""
Convert IPython Notebooks to a simple Python script

Usage: {} Notebook.ipynb

The output should be convertible back to a notebook, but this is not implemented.

Luis Pedro Coelho (luis@luispedro.org)
""")
    sys.exit(1)

json_in = read(open(sys.argv[1]), 'json')

def add_linestart(content, header):
    '''Adds ``header`` to the start of every line in ``content``'''
    lines = content.split('\n')
    lines = [(header + line) for line in lines]
    return '\n'.join(lines)

for sheet in json_in.worksheets:
    for cell in sheet.cells:
        if cell.cell_type == 'code' and cell.language == 'python':
            print(cell.input)
            print('\n')
        elif cell.cell_type == 'heading':
            header = '#M ' + ''.join(['#' for _ in range(cell.level)])
            print(add_linestart(cell.source, header))
            print('\n')
        elif cell.cell_type == 'markdown':
            header = '#M '
            print(add_linestart(cell.source, header))
            print('\n')
        elif cell.cell_type == 'raw':
            header = '#R '
            print(add_linestart(cell.source, header))
            print('\n')
        else:
            raise ValueError('Sorry, mate, I cannot process this cell: {}'.format(cell))
