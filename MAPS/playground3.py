#!/usr/bin/env python

from osgeo import gdal, ogr, osr
from geopy.distance import *
from bclib import *


# Open the shapefile

shapefile = ogr.Open("/home/user/NOBACKUP/EARTHDATA/NATURALEARTH/10m_cultural/ne_10m_admin_0_scale_rank_minor_islands.shp")

layer = shapefile.GetLayer()

polys = ogr.Geometry(ogr.wkbGeometryCollection)

# print(debug0(object=shapefile, exclude="__"))

for i in range(layer.GetFeatureCount()):

  if i > 500:
      print("TESTING!")
      break
    
  feature = layer.GetFeature(i)
  geometry = feature.GetGeometryRef()
#  print(debug0(object=feature, exclude="__"))

  items = feature.items()
  if (items['sr_adm0_a3'] == 'USA'):
#      print(feature.items())
      polys = polys.Union(feature.GetGeometryRef())

# print(polys)

point = (51.509865, -0.118092)
point2 = (35.1, -106.5)

print(great_circle(point, point2))

print(point.Distance(polys))

# dist = great_circle(polys, point).meters

# print(dist)


 # Create the raster dataset
# x_res = y_res = 30
# x_min, x_max, y_min, y_max = layer.GetExtent()
# cols = int((x_max - x_min) / x_res)
# rows = int((y_max - y_min) / y_res)
# raster = gdal.GetDriverByName("GTiff").Create("path/to/raster.tif", cols, rows,\
#                                                1, gdal.GDT_Byte)
# raster.SetGeoTransform((x_min, x_res, 0, y_max, 0, -y_res))
 
