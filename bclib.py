# NOTE: I'm following the same style I use in ../bclib.js in terms of
# named parameters and objects

from math import *
import sys

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
    
    obj['px'] = floor((obj['x'] - floor(obj['x']))*256)
    obj['py'] = floor((obj['y'] - floor(obj['y']))*256)
    obj['x'] = floor(obj['x'])
    obj['y'] = floor(obj['y'])
    
    return obj


def debug0(**obj):
    
    """
    Given an object "object", print keys and values using 'dir'
    
    If exclude=x is set, exclude keys that start with x
    """
    
    for i in dir(obj['object']):
        if (obj.get('exclude') and i.find(obj.get('exclude')) == 0):
            continue
        
        print(i,' -> ',getattr(obj['object'],i))
    


def die(str):
    print(str)
    exit(-1)


def warn(str):
    sys.stderr.write(str)

