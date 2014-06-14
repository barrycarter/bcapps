#!/usr/bin/python

import ephem;




e = ephem.Observer();
e.date = '2013/01/01 00:00:00';
moon = ephem.Moon();
moon.compute(e);
print moon.ra, moon.dec

e.date -= ephem.delta_t(e.date) * ephem.second
print e
moon.compute(e);
print moon.ra, moon.dec

die

moon, e = ephem.Moon(), ephem.Observer()
e.date = '2013/01/01 00:00:00'
moon.compute(e)
print moon.a_ra / ephem.degree, moon.a_dec / ephem.degree


# print ephem.delta_t()*ephem.second

# quit

# e = ephem.Observer();
# print e.next_rising(ephem.Saturn());
