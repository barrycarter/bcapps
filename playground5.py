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
print nsrise(datetime(2011,5,16,12), '89.5', '0', '-0:34', obs.previous_setting, ephem.Sun(), 1)

