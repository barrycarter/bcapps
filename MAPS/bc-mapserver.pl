#!/bin/perl -0777

# TODO: I might be able to use this via xinetd or websocket proxy, see
# if I want do to that though

# The main map server

require "/usr/local/lib/bclib.pl";

debug(mapData(str2hashref("z=5&x=14&y=22")));

for $x (0..31) {
  
  for $y (0..31) {

    mapData(str2hashref("z=5&x=$x&y=$y"));
}

}


=item mapData(%hash)

Given hash below, return the associated data in the data field of a hash:

name: name of the map, either a SHP file or a TIF

z, x, y: the z/x/y tile desired, on a equirectanagular projection

=cut

sub mapData {

  my($hashref) = @_;
  my($out, $err, $res);

  # determine lat/lng extents

  # tile width/height in degrees

  my($width) = 360/2**$hashref->{z};

  my($wlng) = $hashref->{x}*$width - 180;
  my($elng) = $wlng + $width;

  my($nlat) = 90-$hashref->{y}*$width/2;
  my($slat) = $nlat - $width/2;

  debug("RANGES ($hashref->{z}/$hashref->{x}/$hashref->{y}): $wlng - $elng and $slat - $nlat");


  # if the name ends in shp, we use gdal_rasterize

  if ($hashref->{name}=~/\.shp$/i) {
    ($out, $err, $res);
  }




}






die "TESTING";

# TODO: generalize these paths
require "$bclib{githome}/MAPS/bc-mapserver-lib.pl";
require "$bclib{githome}/MAPS/bc-mapserver-commands.pl";

my($ans) = process_command(str2hashref("cmd=time&foo=bar&i=hero"));

# user won't be able to call this, but I can for testing

for ($i=35; $i<36; $i += 1/$meta{landuse}{dataPointsPerDegree}) {
  for ($j=-107; $j<-106; $j += 1/$meta{landuse}{dataPointsPerDegree}) {
    $ans = landuse(str2hashref("lat=$i&lon=$j"));
    print "$i $j $ans->{value}\n";
  }
}

$ans = landuse(str2hashref("lat=35.05&lon=-106.5"));

debug(var_dump("ans", $ans));




