#!/usr/bin/python

# given the location and time, print various rise/set times (to be
# called by a Perl program later)

# Call as: $0 longitude latitude date(yyyy/mm/dd)
# TODO: add elevation
# TODO: go further back and forward to avoid circumpolarity glitches

import ephem;
from sys import argv;

obs = ephem.Observer();
obs.long,obs.lat,date,obs.pressure=argv[1],argv[2],argv[3],0
obs.date = date;
obs.horizon='-0:34'

# everything but the sun <h>(that's a song title, no?)</h>
for i in ["Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn"]:
    for j in ["previous_rising", "previous_setting", "next_rising", "next_setting", "next_transit", "previous_transit"]:
        for k in ["00","12"]:
            obs.date = date+" "+k+":00:00"
            obj = getattr(ephem,i)()
            m = getattr(obs, j)
            # thing to print
            try:
                s = m(obj)
            except(ephem.AlwaysUpError):
                s = "ALWAYSUP"
            except(ephem.NeverUpError):
                s = "NEVERUP"
        
            print i,j,s

# Sun at various heights, I don't use nautical or astro (yet)
for h in ['-0:34', '-6:00', '-12:00', '-18:00']:
    obs.horizon = h
    for j in ["previous_rising", "previous_setting", "next_rising", "next_setting"]:
        for k in ["00","12"]:
            obs.date = date+" "+k+":00:00"
            m = getattr(obs, j)
            try:
                s = m(ephem.Sun())
            except(ephem.AlwaysUpError):
                s = "ALWAYSUP"
            except(ephem.NeverUpError):
                s = "NEVERUP"
        print "Sun"+h,j,s

    
