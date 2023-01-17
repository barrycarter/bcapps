#!/usr/bin/env python

# playground4 attempts to replicate what I did in Mathematica

import os
import cv2
import numpy
import pickle

# TODO: how can I use just `import PIL` here?

from PIL import Image, ImageFilter

# from osgeo import gdal, ogr, osr
# from geopy.distance import *
# from math import *
# from PIL import Image, ImageFilter
# from bclib import *

# this program-specific subroutine finds the edges/shorelines of the
# raster map; params is currently unused

def find_edges(**params):

  # TODO: maybe check more than just file exists

  if os.path.exists("/home/user/BCGIT/tmp/usa-border.png"):
      return

  # NOTE: PIL's ImageFilter works WAY better than Canny, etc, not sure
  # why people like those other methods better, since they are less
  # accurate (I found out after hours of wasting time with them)

  # open the bmp image, find edges, save it to new file

  im = Image.open("/home/user/BCGIT/tmp/usa-raster.bmp")
  edges = im.filter(ImageFilter.FIND_EDGES)
  edges.save("/home/user/BCGIT/tmp/usa-border.png")

# convert a monochrome (not greyscale) image in a file to list of 2D
# "lit" pixels

def image2litPixels(file):

  im = Image.open(file)
  pixels = numpy.array(im)
  return numpy.where(pixels != 0)

############ MAIN CODE STARTS HERE ############

# Note: /home/user/BCGIT/tmp/ is ignored by git but is just an easy place to keep files and symbolic links

# TODO: since gdal_rasterize is itself written in Python, I could
# theoretically do the below directly in code, without having to call
# gdal_rasterize

# raster created by:

# gdal_rasterize -burn 255 -where "sr_adm0_a3 = 'USA'" -ts 18000 9000 -ot Byte ~/BCGIT/tmp/ne_10m_admin_0_scale_rank_minor_islands.shp -of bmp -te -180 -90 180 90 ~/BCGIT/tmp/usa-raster.bmp

# 1 degree transfers to this many pixels (fixed for now, based on gdal_rasterize command above, but may change later)

factor = 5

find_edges()

# compute border and store to file if not already there
# TODO: should this be a function?

if not os.path.exists("/home/user/BCGIT/tmp/border-pixels.txt"):

  lit = image2litPixels("/home/user/BCGIT/tmp/usa-border.png")

  # pickle

  f = open('/home/user/BCGIT/tmp/border-pixels.txt', 'wb')

  pickle.dump(lit, f)

  f.close()

# unpickle

lit = pickle.load(open('/home/user/BCGIT/tmp/border-pixels.txt', 'rb'))

# the x and y values of lit pixels (in this order)

y, x = lit

# project latitude and longitude to 3 dimensions




print(x)

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
 
