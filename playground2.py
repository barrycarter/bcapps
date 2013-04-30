#!/usr/local/bin/python

import ephem

e = ephem.Observer();
e.date = '2013/01/01 00:00:00';
sun = ephem.Sun();
sun.compute(e);
print sun.ra, sun.dec

exit(0);



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
