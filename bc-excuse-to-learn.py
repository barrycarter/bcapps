#!/usr/local/bin/python

# This is my excuse to learn Python by creating Voronoi and Delaunay
# maps for various atmospheric data, using "the cloud". This should be
# more efficient than doing these maps separately

import cloud, os, csv, math, string

# how much water can air at 'temperature' (in Celsius) hold
def saturationVaporPressure(temperature):
    # from http://www.ehow.com/how_8279076_calculate-relative-humidity-dewpoint.html
    L = 2.453*10**6
    Rv = 461
    T = float(temperature)+273.15
    return 6.11*math.exp((L/Rv)*(1/273-1/T))

def doWeatherStuff():

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
        os.system("/usr/local/bin/parallel -j 0 < parallel 1> par.out 2> par.err")

    reader = csv.DictReader(open("metar.txt"))

    # fields I want, and a hash to store them in (+ computed value)
    fields = ['temp_c', 'sea_level_pressure_mb', 'wind_speed_kt']
    data = {}

    for i in fields: data[i] = []
    # special case
    data['humidity'] = [] 

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

    # parallel compute del and vor
    par2 = open("parallel2", "w")

    # write files for qhull
    for i in data.keys():
        f = open(i,"w")
        f.write("2\n")
        f.write(str(len(data[i]))+"\n")
        f.write(string.join(map(lambda x: x[0]+' '+x[1], data[i]),"\n")+"\n")
        f.close()

        par2.write("qvoronoi s o < "+i+" > vor"+i+" 2> /dev/null\n")
        par2.write("qdelaunay i < "+i+" > del"+i+" 2> /dev/null\n")

    par2.close()
    os.system("parallel -j 0 < parallel2")

    # TODO: mercator vs linear
    # write delauney kml files
    for i in data.keys():
        of = open("del"+i+".kml","w")
        of.write('''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
''')
        poly = open("del"+i).readlines()
        # remove first item (length)
        del poly[0]
        for j in poly:
#            polyid+=1
# <!-- <styleUrl>#XXXX</styleUrl> -->
            of.write('''
<Placemark>
<description>XXXX</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
''')
            for k in j.split():
                of.write(data[i][int(k)][1]+","+
                         data[i][int(k)][0]+"\n")
            of.write('''
</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>
''')
            
        of.write("</Document></kml>")

    # at the moment, this is pointless
    print "TODO: restore rsync below"
#    os.system("rsync -e 'ssh -i /usr/local/etc/id_rsa' del* vor* root@data.barrycarter.info:/tmp/")

doWeatherStuff()
# cloud.call(doWeatherStuff, _env = "barryenv1", _profile = True)

