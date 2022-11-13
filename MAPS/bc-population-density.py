#!/usr/local/bin/bython -k

import sys
import os
import rasterio
import xarray
from math import *
from bclib import *

# testing lngLat2Tile

print(lngLat2Tile(lng=-20, z=4, lat=50))

# TODO: create a library to canonize bclib(home) and stuff

fname = "/home/user/NOBACKUP/EARTHDATA/POPULATION/gpw_v4_population_count_rev11_2020_30_sec.tif"

# uncomment this to show you can load 100G+ files without putting them in memory

fname = "/home/user/NOBACKUP/EARTHDATA/ELEVATION/SRTM1/srtm1.tif"

# pt = xarray.open_rasterio(fname)

# print(pt)

print("I has done a compile")

# TODO: put these functions into a library

# NOTE: I'm following the same style I use in ../bclib.js in terms of
# named parameters and objects

def add(x,y):return x+y


