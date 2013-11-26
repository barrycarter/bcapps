#!/usr/local/bin/python

import ephem
atlanta = ephem.Observer()
atlanta.pressure = 0
atlanta.horizon = '-0:34'
atlanta.lat, atlanta.lon = '89:30', '0'
atlanta.date = '2013/11/26 18:38'
print atlanta.next_setting(ephem.Moon())
