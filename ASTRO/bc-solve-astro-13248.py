#!/usr/bin/python

import ephem

obs = ephem.Observer();
obs.long,obs.lat=0,0;
print obs.sidereal_time();

j = ephem.Jupiter('2007/12/6')
print j.g_ra, j.g_dec;
// print ephem.city('Greenwich').sidereal_time()


