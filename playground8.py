#!/usr/local/bin/python3

from skyfield.api import earth
years = range(-9999, 9999, 10)
north_pole = earth.topos('90 N', '0 W')
x, y, z = north_pole.gcrs(utc=(years, 1, 1)).position.km
