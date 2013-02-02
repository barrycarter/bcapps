#!/usr/local/bin/python

import ephem
atlanta = ephem.Observer()
atlanta.pressure = 0
atlanta.horizon = '-0:34'
atlanta.lat, atlanta.lon = '89:30', '0'
atlanta.date = '2011/03/18 12:00'
print atlanta.previous_rising(ephem.Sun())
print atlanta.next_setting(ephem.Sun())
atlanta.date = '2011/03/19 12:00'
print atlanta.previous_rising(ephem.Sun())
print atlanta.next_setting(ephem.Sun())
atlanta.date = '2011/03/20 12:00'
print atlanta.previous_rising(ephem.Sun())
# print atlanta.next_setting(ephem.Sun())
atlanta.date = '2011/09/24 12:00'
# print atlanta.previous_rising(ephem.Sun())
print atlanta.next_setting(ephem.Sun())
atlanta.date = '2011/09/25 12:00'
print atlanta.previous_rising(ephem.Sun())
print atlanta.next_setting(ephem.Sun())
atlanta.date = '2011/09/26 12:00'
print atlanta.previous_rising(ephem.Sun())
print atlanta.next_setting(ephem.Sun())
