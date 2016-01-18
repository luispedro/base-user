#!/usr/bin/env python

import sys
import numpy as np

method = sys.argv[1]
field = (int(sys.argv[2]) if len(sys.argv) > 2 else None)

data = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    if field:
        line = line.split()[field]
    data.append(float(line))

data = np.array(data)

if method == 'sum':
    print(np.sum(data))
elif method == 'mean':
    print(np.mean(data))
elif method == 'max':
    print(np.max(data))
elif method == 'min':
    print(np.min(data))
elif method == 'ptp':
    print(np.ptp(data))
elif method == 'maxabs':
    print(np.max(np.abs(data)))
else:
    print("Unknown method: {}".format(method))
