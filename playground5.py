#!/usr/bin/python

import ephem, sys
from sys import argv
from datetime import datetime, timedelta

def nsrise(date, horizon, f, object, seek=1):
    obs.date,obs.horizon = date,horizon
    print "OBS",obs
    try: return f(object)
    except (ephem.AlwaysUpError, ephem.NeverUpError): return nsrise(date+timedelta(hours=12*seek), horizon, f, object, seek)

obs = ephem.Observer()
obs.lat,obs.long,date,obs.pressure=argv[1],argv[2],argv[3],0
print obs

print "SR",nsrise(date,'-0:34',obs.previous_rising, ephem.Sun(),-1)
print "SS",nsrise(date,'-0:34',obs.previous_setting, ephem.Sun(),-1)
print "SR",nsrise(date,'-0:34',obs.next_rising, ephem.Sun(),+1)
print "SS",nsrise(date,'-0:34',obs.next_setting, ephem.Sun(),+1)

print "CTS",nsrise(date,'-6',obs.previous_rising, ephem.Sun(),-1)
print "CTE",nsrise(date,'-6',obs.previous_setting, ephem.Sun(),-1)
print "CTS",nsrise(date,'-6',obs.next_rising, ephem.Sun(),+1)
print "CTE",nsrise(date,'-6',obs.next_setting, ephem.Sun(),+1)

print "MR",nsrise(date,'-0:34',obs.previous_rising, ephem.Moon(),-1)
print "MS",nsrise(date,'-0:34',obs.previous_setting, ephem.Moon(),-1)
print "MR",nsrise(date,'-0:34',obs.next_rising, ephem.Moon(),+1)
print "MS",nsrise(date,'-0:34',obs.next_setting, ephem.Moon(),+1)
