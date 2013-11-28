#!/usr/bin/python

import ephem;

e = ephem.Observer();
print e.next_rising(ephem.Saturn());
