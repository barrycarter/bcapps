ogr2ogr -f CSV joined.csv -sql "SELECT u.GEOID, STATEFP, ALAND, AWATER, INTPTLAT, INTPTLON, B01003e1 FROM ACS_2014_5YR_BG u JOIN X01_AGE_AND_SEX v ON u.GEOID_Data = v.GEOID" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip

exit;

ogr2ogr -f CSV temp1.csv -sql "SELECT GEOID_Data, STATEFP, ALAND, AWATER, INTPTLAT, INTPTLON FROM ACS_2014_5YR_BG" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip; sort temp1.csv > temp1.csv.srt &

ogr2ogr -f CSV temp2.csv -sql "SELECT GEOID, B01003e1 FROM X01_AGE_AND_SEX" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip; sort temp2.csv > temp2.csv.srt &

join -t, temp[12].csv.srt > blockgroups.txt

exit;

# query that gives me all census blockgroups (but its too slow, the method above is MUCH faster)

ogr2ogr -f CSV joined.csv -sql "SELECT u.GEOID, STATEFP, ALAND, AWATER, INTPTLAT, INTPTLON, B00001e1 FROM ACS_2014_5YR_BG u JOIN X00_COUNTS v ON u.GEOID_Data = v.GEOID" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip

exit;

# in theory, a single join (as below) should let me get
# size/population/location area for all census blockgroups at once,
# but I keep getting empty columns for some reason, so I'm doing it in
# two steps and using text join (note GEOID MUST be first column since
# I will join against it)

ogr2ogr -f CSV bg2.csv -sql "SELECT GEOID, B00001e1 FROM X00_COUNTS" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip

# ogr2ogr -f CSV bg1.csv -sql "SELECT GEOID, STATEFP, ALAND, AWATER, INTPTLAT, INTPTLON FROM ACS_2014_5YR_BG" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip

exit;

ogr2ogr -f CSV output.csv -sql "SELECT GEOID, B00001e1 FROM X00_COUNTS" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip

exit;

ogr2ogr -f CSV output.csv -sql "SELECT GEOID, B00001e1 FROM X00_COUNTS" /home/barrycarter/CENSUS/ACS_2014_5YR_BG.gdb.zip

exit;

# generates a file that, after cleanup, can be used to load tracts
# into Mathematica for plotting

echo "SELECT '{'||intptlong||','||intptlat||'},' FROM tracts;" | sqlite3 tracts.db > /tmp/tracts.m

exit;
