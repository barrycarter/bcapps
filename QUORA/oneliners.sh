# generates a file that, after cleanup, can be used to load tracts
# into Mathematica for plotting

echo "SELECT '{'||intptlong||','||intptlat||'},' FROM tracts;" | sqlite3 tracts.db > /tmp/tracts.m

