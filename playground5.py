#!/usr/bin/python

import ephem
from datetime import datetime, timedelta

def nsrise(date, lat, long, horizon):
    obs = ephem.Observer()
    obs.date, obs.lat, obs.long, obs.horizon, obs.pressure = date, 'lat', 'long', horizon, 0
    return obs.next_rising(ephem.Sun())

print nsrise(datetime(2013,2,1), 35, -106.5, 0)

obs = ephem.Observer()
obs.date, obs.lat, obs.long, obs.horizon, obs.pressure = datetime(2013,2,1), '35', '-106.5', 0, 0
print obs
print obs.next_rising(ephem.Sun())
