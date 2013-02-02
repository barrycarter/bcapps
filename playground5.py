#!/usr/bin/python

import ephem
from datetime import datetime, timedelta

def nsrise(date, lat, long, horizon):
    obs = ephem.Observer()
    obs.date, obs.lat, obs.long, obs.horizon, obs.pressure = date, lat, long, horizon, 0
    try:
        return obs.next_rising(ephem.Sun())
    except (ephem.AlwaysUpError, ephem.NeverUpError):
        return nsrise(date+timedelta(hours=12), lat, long, horizon)



print nsrise(datetime(2012,5,16,12), '70', '0', '-0:34')

