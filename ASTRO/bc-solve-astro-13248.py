#!/usr/bin/python

import ephem, math

obs = ephem.Observer();
obs.long,obs.lat=0,0;
pl = ephem.Pluto(ephem.now())
print 180.*(pl.g_ra-obs.sidereal_time())/math.pi,180.*pl.g_dec/math.pi
