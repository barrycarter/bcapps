#!/bin/perl -0777

# TODO: I might be able to use this via xinetd or websocket proxy, see
# if I want do to that though

# The main map server

require "/usr/local/lib/bclib.pl";

# TODO: full pathify

mapData(str2hashref("z=0&x=0&y=0&name=ne_10m_time_zones.shp&layer=objectid"));

=item mapData(%hash)

Given hash below, return the associated data in the data field of a hash:

name: name of the map, either a SHP file or a TIF

z, x, y: the z/x/y tile desired, on a equirectanagular projection

layer: the layer to burn

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

  # with of a pixel, for gdal_rasterize or warp
  my($tr) = $width/256;


  debug("RANGES ($hashref->{z}/$hashref->{x}/$hashref->{y}): $wlng - $elng and $slat - $nlat");


  # if the name ends in shp, we use gdal_rasterize

  if ($hashref->{name}=~/\.shp$/i) {
    # TODO: using Int16 here is unnecessary in some cases
    # TODO: of course, we may need Float or something later, so bad both ways
    # TODO: nonfixed tmpfile

    my($cmd) = "gdal_rasterize -ot Int16 -tr $tr $tr -te $wlng $slat $elng $nlat -of Ehdr -a $hashref->{layer} $hashref->{name} /tmp/output.bin";

    debug($cmd);

    ($out, $err, $res) = cache_command2($cmd, "age=3600");
  }

  return read_file("/tmp/output.bin");

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




