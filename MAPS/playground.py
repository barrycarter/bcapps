#!/usr/local/bin/bython -k

import sys
import os
import xarray
from bclib import *

fname = "/home/user/NOBACKUP/EARTHDATA/POPULATION/gpw_v4_population_count_rev11_2020_30_sec.tif"

pt = xarray.open_rasterio(fname)

for i in range(len(pt[0])):
    print(list(pt[0][i]))



