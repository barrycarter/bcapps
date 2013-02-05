#!/usr/bin/python

import ephem
from datetime import datetime, timedelta

obs = ephem.Observer()
obs.lat = '70:00'
obs.long = '0'
obs.horizon= '-0:00'
# print obs.horizon

start = datetime(2012, 1, 1)
end = datetime(2013, 1, 1)
step = timedelta(minutes=720)

sun = ephem.Sun()

timestamp = start
while timestamp < end:
    obs.date = timestamp

    try:
        print obs.next_rising(sun)
    except (ephem.AlwaysUpError, ephem.NeverUpError):
        pass
    
    try:
        print obs.next_setting(sun)
    except (ephem.AlwaysUpError, ephem.NeverUpError):
        pass

    try:
        print obs.previous_rising(sun)
    except (ephem.AlwaysUpError, ephem.NeverUpError):
        pass

    try:
        print obs.previous_setting(sun)
    except (ephem.AlwaysUpError, ephem.NeverUpError):
        pass
    
    timestamp += step
