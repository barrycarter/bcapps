#!/usr/bin/python
import ephem;

# Barrow, AK
obs = ephem.Observer()
obs.long = '-156.788708972258'
obs.lat = '71.2905771309481'
obs.horizon = '-0:34'
obs.date = '2014/01/22 00:00:00'

print obs.next_rising(ephem.Sun())
