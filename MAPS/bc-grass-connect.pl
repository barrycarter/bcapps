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

debug(vect2rast(str2hashref("slat=25&nlat=50&wlng=-120&elng=-60&map=ne_10m_time_zones&feature=cat")));

die "TESTING";

my($out, $err, $res);

($out, $err, $res) = cache_command2("g.region n=50 s=30 w=-120 e=-70 rows=256 cols=256");

($out, $err, $res) = cache_command2("v.to.rast --overwrite input=ne_10m_time_zones output=temp use=cat");

debug("OUT: $out, ERR: $err, RES: $res");

($out, $err, $res) = cache_command2("r.out.gdal --overwrite input=temp output=/tmp/GDAL-1234.png format=EHdr");

debug("BETA");

=item vect2rast(%hash)

Given a hash with the following, return a hash whose data element is
raw data representing portion of vector map:

map - the name of the vector map, eg "ne_10m_time_zones"

feature - the feature to use for rasterization (eg, "cat")

slat, nlat, wlng, elng - Portion to extract

=cut

sub vect2rast {

  # this is just internal, but global
  $count++;

  my($hashref) = @_;

  my($cmd) = << "MARK";
g.region n=$hashref->{nlat} s=$hashref->{slat} w=$hashref->{wlng} e=$hashref->{elng} rows=256 cols=256
v.to.rast --overwrite input=$hashref->{map} output=bc-grass-connect-$count use=$hashref->{feature}
r.out.gdal --overwrite input=bc-grass-connect-$count output=/tmp/bc-grass-connect-$count format=EHdr
MARK
;

  debug("CMD: $cmd");

  my($out, $err, $res) = cache_command2($cmd);

  debug("OUT: $out, ERR: $err, RES: $res");

  return read_file("/tmp/bc-grass-connect-$count");
}


