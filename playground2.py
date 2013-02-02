#!/usr/local/bin/python

import ephem
atlanta = ephem.Observer()
atlanta.horizon, atlanta.lat, atlanta.lon, atlanta.date, atlanta.pressure = '-0:34', '70', '0', '2012/07/14 12:00:00', 0



try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"

try: print "NSRISE",atlanta.next_rising(ephem.Sun())
except: print "NONE"

try: print "PSSET",atlanta.previous_setting(ephem.Sun())
except: print "NONE"

try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
try: print "PSRISE",atlanta.previous_rising(ephem.Sun())
except: print "NONE"
