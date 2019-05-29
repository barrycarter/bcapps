#!/bin/perl

# this script (which will eventually be a daemon or connected to
# existing daemon) connects to the GRASS shell to create data files on
# demand from vector maps

require "/usr/local/lib/bclib.pl";

# gisrc file grass needs (is normally created each time)

# TODO: this file should be less temporary

my($tmp) = my_tmpfile2();

my($str) = << "MARK";
MAPSET: PERMANENT
GISDBASE: /home/user/GRASS
LOCATION_NAME: naturalearth
GUI: text
PID: $$
MARK
;

write_file($str, $tmp);

$ENV{GISRC} = $tmp;

# ENV grass needs

$ENV{GISBASE} = "/usr/local/grass-7.4.1";

$ENV{LD_LIBRARY_PATH} = "/usr/local/grass-7.4.1/lib:$ENV{LD_LIBRARY_PATH}";

$ENV{PATH} = "/usr/local/grass-7.4.1/bin:/usr/local/grass-7.4.1/scripts:$ENV{PATH}";

$ENV{GRASS_VERSION} = "7.4.1";

# let's run this program from WITHIN grass

# intentionally omitting /home/user/.grass7 from path

my($out, $err, $res);

($out, $err, $res) = cache_command2("v.colors map=ne_10m_time_zones color=roygbiv use=attr column=zone");

debug("OUT: $out, ERR: $err, RES: $res");

($out, $err, $res) = cache_command2("g.region n=50 s=30 w=-120 e=-70 rows=256 cols=256");

debug("OUT: $out, ERR: $err, RES: $res");

($out, $err, $res) = cache_command2("v.to.rast --overwrite input=ne_10m_time_zones output=temp use=cat");

debug("OUT: $out, ERR: $err, RES: $res");

($out, $err, $res) = cache_command2("r.out.gdal --overwrite input=temp output=/tmp/GDAL-1234.png format=PNG");

debug("BETA");

