#!/usr/local/bin/python

import ephem
atlanta = ephem.Observer()
atlanta.pressure = 0
atlanta.horizon = '-0:34'
atlanta.lat, atlanta.lon = '33.8', '-84.4'
atlanta.date = '2009/09/06 17:00'
print atlanta.previous_rising(ephem.Sun())
print atlanta.next_setting(ephem.Sun())
print atlanta.previous_rising(ephem.Moon())
print atlanta.next_setting(ephem.Moon())
