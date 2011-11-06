#!/usr/local/bin/python

# This is my excuse to learn Python by creating Voronoi and Delaunay
# maps for various atmospheric data, using "the cloud". This should be
# more efficient than doing these maps separately

import cloud;
import os;

# do all work in temporary (but fixed) directory
exists = os.path.isdir("/tmp/bcetlp")
if not(exists): os.mkdir("/tmp/bcetlp")
os.chdir("/tmp/bcetlp")

# get both files I need, in parallel (to save time)
parfile = open("parallel", "w")
parfile.write("curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6 > metar.txt\n")
parfile.write("curl -o buoy.txt http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt\n")
parfile.close()

print "ALPHA"

os.system("ls -l")
print os.system("cat parallel 1> output")
os.system("/usr/local/bin/parallel < parallel 1> par.out 2> par.err")


