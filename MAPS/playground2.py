#!/usr/bin/env python

# note: above is python2.7 which seems to not be failing

from bclib import *
import shapefile
import matplotlib.pyplot as plt

sf = shapefile.Reader("ne_10m_time_zones.shp")

# print(sf.shapes())

# print(sf.shapeRecords())

# for i in sf.shapeRecords():
#    debug0(object=i)

sr = sf.shapeRecords()

sh = sr[0].record.time_zone

# print(sh)

# debug0(object=sh)

tz = (filter(lambda x: x.record.tz_name1st == 'America/Denver', sf.shapeRecords()))[0]

debug0(object=tz, exclude="__")

print(tz.shape.points)

x = [point[0] for point in tz.shape.points]
y = [point[1] for point in tz.shape.points]

plt.plot(x,y)
plt.show()







