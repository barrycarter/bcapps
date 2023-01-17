#!/usr/bin/env python

# playground4 attempts to replicate what I did in Mathematica

import cv2
from osgeo import gdal, ogr, osr
from geopy.distance import *
import numpy as np
from math import *
from PIL import Image, ImageFilter
from bclib import *

# raster created by:

# gdal_rasterize -burn 255 -where "sr_adm0_a3 = 'USA'" -ts 18000 9000 -ot Byte ~/NOBACKUP/EARTHDATA/NATURALEARTH/10m_cultural/ne_10m_admin_0_scale_rank_minor_islands.shp -of bmp -te -180 -90 180 90 /tmp/temp.bmp

# TODO: add caching

# im = Image.open("/tmp/temp.bmp")

im = cv2.imread("/tmp/temp.bmp", -1)

im = Image.open("/tmp/temp.bmp")
edges = im.filter(ImageFilter.FIND_EDGES)

edges.save("/tmp/output.png")

# kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2,2))

# edges = cv2.morphologyEx(im, cv2.MORPH_GRADIENT, kernel)

# edges = cv2.Canny(im, 0, 255)

# cv2.imwrite("/tmp/output.png", edges)

exit(0)

# kernel = np.ones((2, 2), np.uint8)

cv2.imwrite("/tmp/output.png", edges)

exit(0)

cntrs = cv2.findContours(im, cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)

print(np.shape(cntrs))

print(cntrs[1])

# im2 = cv2.cvtColor(im, cv2.CV_32SC1)

# print(im2.dtype)

# val, im2 = cv2.threshold(im, 0.5, 1, cv2.THRESH_BINARY)

# print(im[100][200])


# print("VAL",val)

# cv2.imshow('image', im2)

# cv2.waitKey(0)

# this is (9000, 18000, 3)

# print(np.shape(im))


# cv2.imshow('image', im2)

exit(0)

# print(im2)

exit(0)

pixels = np.array(im)

print(pixels[1][1])

white = np.where(pixels != 0)

print(np.shape(white))

print(white[1])

contour = find_contours(pixels, 0.5)

print(contour)

exit(0)

# sph2xyz fast?

latitudes = np.linspace(-90, 90, 5400, endpoint=True) * np.pi / 180
longitudes = np.linspace(-180, 180, 10800, endpoint=True) * np.pi / 180

mylats, mylons = np.meshgrid(latitudes, longitudes)

mylats = mylats.flatten()
mylons = mylons.flatten()

print(len(mylats))

x = np.cos(mylats)*np.cos(mylons)
y = np.cos(mylats)*np.sin(mylons)
z = np.sin(mylats)

print(len(x))

print("DONE COMPUTING")

exit(0)

latitudes = np.arange(start=-90, stop=90, step=180./5400/2)*pi/180
longitudes = np.arange(start=-180, stop=180, step=360./10800/2)*pi/180

mylats = np.array([])
mylons = np.array([])

for i in latitudes:
    for j in longitudes:
        # there has to be a better way to do this
        mylats = np.append(mylats, i)
        mylons = np.append(mylons, i)



x = np.cos(mylats)*np.cos(mylons)

y = np.cos(mylats)*np.sin(mylons)

z = np.sin(mylats)

exit(0)

longitudes = np.array([-75, -80, -85]) # in degrees
latitudes = np.array([35, 40, 45]) # in degrees
altitudes = np.array([0, 1000, 2000]) # in meters

# Convert the spherical coordinates to radians
longitudes_rad = np.radians(longitudes)
latitudes_rad = np.radians(latitudes)

# Convert the spherical coordinates to Cartesian coordinates
x = altitudes * np.cos(latitudes_rad) * np.cos(longitudes_rad)
y = altitudes * np.cos(latitudes_rad) * np.sin(longitudes_rad)
z = altitudes * np.sin(latitudes_rad)

print(longitudes)

exit(0)

# Open the shapefile

shapefile = ogr.Open("/home/user/NOBACKUP/EARTHDATA/NATURALEARTH/10m_cultural/ne_10m_admin_0_scale_rank_minor_islands.shp")

layer = shapefile.GetLayer(0)

# query = f"{attribute_name} = '{attribute_value}'"

# below does not work
# layer.SetAttributeFilter("sr_adm0_a3 = 'USA'")

# print(layer)

# polys = ogr.Geometry(ogr.wkbGeometryCollection)

# print(debug0(object=shapefile, exclude="__"))

for i in range(layer.GetFeatureCount()):

#  if i > 10000:
#      print("TESTING!")
#      break
    
  feature = layer.GetFeature(i)
  geometry = feature.GetGeometryRef()
#  print(debug0(object=feature, exclude="__"))

  items = feature.items()

  if (items['sr_adm0_a3'] == 'USA'):
      
    print("FOUND USA", i)
    geom = feature.GetGeometryRef()
#    print("GEOM IS", geom.GetPoint(7))
#    for j in range(geom.GetPointCount()):
#      x, y, z = geom.GetPoint(i)
#      print(x,y,z)
      
#      print(feature.items())
#      polys = polys.Union(feature.GetGeometryRef())






exit(0)

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
 
