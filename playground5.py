#!/usr/bin/python

import ephem, sys
from sys import argv
from datetime import datetime, timedelta

def nsrise(horizon, f, object, seek=1):
    obs.horizon = horizon
    try: return f(object)
    except (ephem.AlwaysUpError, ephem.NeverUpError): return nsrise(date+timedelta(hours=12*seek), lat, long, horizon, f, object, seek)

obs = ephem.Observer()
obs.lat,obs.long,obs.date,obs.pressure=argv[1],argv[2],argv[3],0
print obs

print "SR",nsrise(date,lat,lon,'-0:34',obs.previous_rising, ephem.Sun(),-1)
print "SS",nsrise(date,lat,lon,'-0:34',obs.next_setting, ephem.Sun(),+1)

print "CTS",nsrise(date,lat,lon,'-6',obs.previous_rising, ephem.Sun(),-1)
print "CTE",nsrise(date,lat,lon,'-6',obs.previous_setting, ephem.Sun(),-1)
print "CTS",nsrise(date,lat,lon,'-6',obs.next_rising, ephem.Sun(),+1)
print "CTE",nsrise(date,lat,lon,'-6',obs.next_setting, ephem.Sun(),+1)

print "MR",nsrise(date,lat,lon,'-0:34',obs.previous_rising, ephem.Moon(),-1)
print "MS",nsrise(date,lat,lon,'-0:34',obs.previous_setting, ephem.Moon(),-1)
print "MR",nsrise(date,lat,lon,'-0:34',obs.next_rising, ephem.Moon(),+1)
print "MS",nsrise(date,lat,lon,'-0:34',obs.next_setting, ephem.Moon(),+1)

