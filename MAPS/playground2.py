#!/usr/bin/env python

# note: above is python2.7 which seems to not be failing

from bclib import *
import shapefile


sf = shapefile.Reader("ne_10m_time_zones.shp")

# print(sf.shapes())

# print(sf.shapeRecords())

# for i in sf.shapeRecords():
#    debug0(object=i)

sr = sf.shapeRecords()

sh = sr[0].record.time_zone

print(sh)

# debug0(object=sh)






