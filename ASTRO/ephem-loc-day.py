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

for i in [ephem.Sun(), ephem.Moon()]:
    for j in ["previous_rising"]:
        m = getattr(obs, j)
        print m(i)
        


sys.exit();

obs.lat,obs.long,obs,date,obs.pressure=argv[1],argv[2],argv[3],argv[4],0;
print obs;

print "SR",nsrise(date,'-0:34',obs.previous_rising, ephem.Sun(),-1)
print "SS",nsrise(date,'-0:34',obs.previous_setting, ephem.Sun(),-1)
print "SR",nsrise(date,'-0:34',obs.next_rising, ephem.Sun(),+1)
print "SS",nsrise(date,'-0:34',obs.next_setting, ephem.Sun(),+1)

print "CTS",nsrise(date,'-6',obs.previous_rising, ephem.Sun(),-1)
print "CTE",nsrise(date,'-6',obs.previous_setting, ephem.Sun(),-1)
print "CTS",nsrise(date,'-6',obs.next_rising, ephem.Sun(),+1)
print "CTE",nsrise(date,'-6',obs.next_setting, ephem.Sun(),+1)

print "MR",nsrise(date,'-0:34',obs.previous_rising, ephem.Moon(),-1)
print "MS",nsrise(date,'-0:34',obs.previous_setting, ephem.Moon(),-1)
print "MR",nsrise(date,'-0:34',obs.next_rising, ephem.Moon(),+1)
print "MS",nsrise(date,'-0:34',obs.next_setting, ephem.Moon(),+1)
