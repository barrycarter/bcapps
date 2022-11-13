#!/usr/local/bin/bython -k

import sys
import os
import rasterio
import xarray
from math import *
from bclib import *

# TODO: create a library (done) and canonize bclib(home) and stuff

fname = "/home/user/NOBACKUP/EARTHDATA/POPULATION/gpw_v4_population_count_rev11_2020_30_sec.tif"

# uncomment this to test that I am not reading thee entire file

fname = "/home/user/NOBACKUP/EARTHDATA/ELEVATION/SRTM1/srtm1.tif"

# pt = rasterio.open(fname)

pt = xarray.open_rasterio(fname)

for i in range(len(pt[0])):
    for j in range(len(pt[0][i])):
        data = pt[0][i][j]
        print(i,j,float(data.x),float(data.y),float(data.data))
    


die("TESTING")

print(len(pt[0]))

# print(pt[0][500][500].data)

# print(debug0(object=pt[0], exclude="_"))

# for i in range(len(pt[0]))) {
#  for j in range(pt[0][i].length) {
#    print(pt[0][i][j])
# }


#  for j in range(pt.width) {
#
#    print(`I: {i}, J: {j}`)
#  }
# }

print(pt.xy(23, 34))

die("TESTING")

# since our data is 43200x21600 we start with level 8 tiles -- this
# will be imperfect

x = list(pt.x)
y = list(pt.y)
vals = list(pt.values)

for i in range(len(x)):
    print(i)
    for j in range(len(y)):
        lat = float(y[j])
        lng = float(x[i])
        pop = float(vals[0][j][i])
    









