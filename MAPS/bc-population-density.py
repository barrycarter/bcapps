#!/usr/local/bin/bython -k

import sys
import os
import rasterio
import xarray
from math import *

def lngLat2Tile(**obj):
    """
    Converts a latitude and longitude to a Mercator-projected slippy tile. Input:
    
    z: tile zoom value
    lat: the latitude
    lng: tile longitude
    
    Output:
    
    x: the tile's x value
    y: the tile's y value
    
    px: the pixel value inside the x tile (rounded)
    py: the pixel value inside the y tile (rounded)
    
    """
    obj['x'] = (obj['lng']+180)/360*2**obj['z']
    
    # The line below does a lot:
    #   - converts latitude to radians
    #   - computes the inverse Gudermannian function
    #   - normalizes the function to go from 0 to 1
    #   - reverse the function to match y increasing = south per OSM
    #   - multiplies by 2^zoomlevel to find the tile number
    
    obj['y'] = 2**obj['z']*(1/2-log(tan(obj['lat']*pi/180) + 1/cos(obj['lat']*pi/180))/2/pi)
    
    # now the pixel values
    
    obj['px'] = round((obj['x'] - floor(obj['x']))*256)
    obj['py'] = round((obj['y'] - floor(obj['y']))*256)
    obj['x'] = floor(obj['x'])
    obj['y'] = floor(obj['y'])
    
    return obj


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


