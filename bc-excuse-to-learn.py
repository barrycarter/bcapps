#!/usr/local/bin/python

# This is my excuse to learn Python by creating Voronoi and Delaunay
# maps for various atmospheric data, using "the cloud". This should be
# more efficient than doing these maps separately

import cloud;
import os;

# do all work in temporary (but fixed) directory
tmpdir = "/tmp/bcetlp"
if not(os.path.isdir(tmpdir)): os.mkdir(tmpdir)
os.chdir(tmpdir)

# TODO: below is just for now; in reality, new copy each time (which
# is actually automatic in cloud...)

if (not(os.path.isfile(tmpdir+"/metar.txt") and os.path.isfile(tmpdir+"/buoy.txt"))):
    parfile = open("parallel", "w")
    parfile.write("curl http://weather.aero/dataserver_current/cache/metars.cache.csv.gz | gunzip | tail -n +6 > metar.txt\n")
    parfile.write("curl -o buoy.txt http://www.ndbc.noaa.gov/data/latest_obs/latest_obs.txt\n")
    parfile.close()
    os.system("/usr/local/bin/parallel < parallel 1> par.out 2> par.err")

metar = open("metar.txt").readlines()

print (metar)


       

       

