#!/usr/bin/python

# given the location and time, print various rise/set times (to be
# called by a Perl program later)

# Call as: $0 latitude longitude date(yyyy/mm/dd)
# TODO: add elevation

import ephem;
from sys import argv;

obs = ephem.Observer();
obs.lat,obs.long,date,obs.pressure=argv[1],argv[2],argv[3],0
obs.date = date;
print obs

for i in ["Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn"]:
    for j in ["previous_rising", "previous_setting", "next_rising", "next_setting"]:
        obj = getattr(ephem,i)()
        m = getattr(obs, j)
        print i,j,m(obj)
