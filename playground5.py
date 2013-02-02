#!/usr/bin/python

import ephem
from datetime import datetime, timedelta

def nsrise(date, lat, long, horizon, f, object, seek=1):
    obs.date, obs.lat, obs.long, obs.horizon, obs.pressure = date, lat, long, horizon, 0
    try:
        return f(object)
    except (ephem.AlwaysUpError, ephem.NeverUpError):
        return nsrise(date+timedelta(hours=12*seek), lat, long, horizon, f, object, seek)

obs = ephem.Observer()
lat, lon, date = '89.5', '0', datetime(2011,5,16,12)
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

