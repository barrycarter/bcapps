#!/usr/local/bin/python

# This is my excuse to learn Python by creating Voronoi and Delaunay
# maps for various atmospheric data, using "the cloud". This should be
# more efficient than doing these maps separately

import cloud;
import os;

# do all work in temporary (but fixed) directory
if (~os.path.isdir("/tmp/bcetlp")): os.mkdir("/tmp/bcetlp")
os.chdir("/tmp/bcetlp")

# get both files I need, in parallel (to save time)
FILE = open("parallel", "w")
FILE.write("curl -o metar.txt http://weather.aero/dataserver_current/cache/metars.cache.csv.gz\n")
FILE.write("curl -o buoy.txt http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt\n")
FILE.close

os.system("parallel < parallel")


