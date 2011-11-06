#!/usr/local/bin/python

# This is my excuse to learn Python by creating Voronoi and Delaunay
# maps for various atmospheric data, using "the cloud". This should be
# more efficient than doing these maps separately

import cloud, os, csv, math

# how much water can air at 'temperature' (in Celsius) hold
def saturationVaporPressure(temperature):
    # from http://www.ehow.com/how_8279076_calculate-relative-humidity-dewpoint.html
    L = 2.453*10**6
    Rv = 461
    T = float(temperature)+273.15
    return 6.11*math.exp((L/Rv)*(1/273-1/T))

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

reader = csv.DictReader(open("metar.txt"))

# fields I want, and a hash to store them in
fields = ['temp_c', 'sea_level_pressure_mb', 'wind_speed_kt']
data = {}
# special case for computed value
data['humidity'] = []
for i in fields: data[i] = []

for row in reader:
    # ignore empty lat/lon
    if (row['latitude'] == "" or row['longitude'] == ""): continue

    for i in fields:
        if (row[i] != ''):
            data[i].append([row['latitude'], row['longitude'], row[i]])

    # compute humidity
    if (row['temp_c'] != '' and row['dewpoint_c'] != ''):
        humidity = saturationVaporPressure(row['dewpoint_c'])/saturationVaporPressure(row['temp_c'])
        data['humidity'].append([row['latitude'], row['longitude'], humidity])


# write files for qhull
for i in data.keys():
    f = open(i,"w")
    f.write("2\n")
    st = map(lambda x: [x[0], x[1]], data[i])
    print st
#    f.write(str(len(data[i]))+"\n")
#    f.close()

    




