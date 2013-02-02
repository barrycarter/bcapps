#!/usr/local/bin/python

import ephem
atlanta = ephem.Observer()
atlanta.pressure = 0
atlanta.horizon = '-0:34'
atlanta.lat, atlanta.lon = '70', '0'
atlanta.date = '2012/07/26 12:00'
print atlanta.previous_rising(ephem.Sun())
atlanta2 = ephem.Observer()
atlanta2.pressure = 0
atlanta2.horizon = '-0:34'
atlanta2.lat, atlanta2.lon = '70.0000000000000001', '0'
atlanta2.date = '2012/07/26 12:00'
print atlanta2.next_setting(ephem.Sun())
