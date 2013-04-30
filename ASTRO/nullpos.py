#!/usr/local/bin/python

# RA/DEC of moon at 0N 0E at 0000 UTC 01 Jan 2013
import ephem; e = ephem.Observer(); e.date = '2013/01/01 00:00:00';
moon = ephem.Moon(); moon.compute(e); print moon.ra, moon.dec


