#!/usr/bin/env python

# note: above is python2.7 which seems to not be failing

from bclib import *
import shapefile
# import gdal
import matplotlib.pyplot as plt
# import zipfile

from shapely.geometry import shape, Point
from shapely.ops import transform

from functools import partial
import pyproj

pt1 = Point(-106.5, 35.1)

pt2 = Point(0, 0)

print(pt1.geodesic(pt2))

exit()

# IMPORTANT: must use zipmount or this file won't exist

sf = shapefile.Reader("/mnt/zip/gadm41_USA_shp.zip/gadm41_USA_0.shp")

usa = (sf.shapes())[0]

usa2 = shape(usa)

print(Point(0,0).geodesic(usa2))

# print(usa2)

# print(usa.geodesic(Point(0,0)))

# print(usa)

x = [point[0] for point in usa.points]
y = [point[1] for point in usa.points]

# plt.plot(x,y)
# plt.show()

# gdf = gdal.Open("/home/user/NOBACKUP/EARTHDATA/GADM/gadm_410-levels.gpkg")

# print(gdf)

exit()

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







