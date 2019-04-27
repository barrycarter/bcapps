#!/bin/python
import fiona
from shapely.geometry import shape,mapping, Point, Polygon, MultiPolygon
multipol = fiona.open("multipol.shp")
multi= multipol.next() # only one feature in the shapefile
print multi

