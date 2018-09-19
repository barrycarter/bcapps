#!/bin/perl

# testbed for trivial map functions will eventually become a CGI

# TODO: have default zoom be based on distance between two points?

# TODO: draw lines that are "10% closer to X than to Y?" (probably not
# easy, not geodesic circles?)

# TODO: on equidistant line, tick off how many miles you are from X
# and Y (the same amount of course)

# TODO: allow multiple points

require "/usr/local/lib/bclib.pl";

die "This code does not work, see my question on gis.stackexchange.com
for details"

# debug(antipode(5,10));

%points = (
 "Albuquerque" => "35.08 -106.66",
 "Paris" => "48.87 2.33",
 "Barrow" => "71.26826 -156.80627",
 "Wellington" => "-41.2833 174.783333",
 "Rio de Janeiro" => "-22.88  -43.28"
);


my(%hash) = %{gcmorestats(
 split(/\s+/, $points{Albuquerque}),
 split(/\s+/, $points{Wellington})
)};

# TODO: this is ugly for many reasons
my($midpt) = join(", ", $hash{midpoint}[1], $hash{midpoint}[0]);
my($quad) = join(", ", $hash{quad}[1], $hash{quad}[0]);
my($pole) = join(", ", $hash{pole}[1], $hash{pole}[0]);

debug($midpt);

# TODO: this is junky for testing right now

my($str) = << "MARK";

<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0px; padding: 0px }
  #map_canvas { height: 100% }
</style>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false">
</script>
<script type="text/javascript">

function initialize() {
  var myOptions = {
    zoom: 8,
    center: new google.maps.LatLng($midpt),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var map = new google.maps.Map(document.getElementById("map_canvas"),
      myOptions);

  // quarter circumference of earth
  var qcirc = 10018754.17;

  var circ = new google.maps.Circle({
   center: new google.maps.LatLng($quad),
   radius: qcirc,
   map: map,
   strokeColor: "#000000",
   strokeWeight: 1,
   fillOpacity: 0
  });
  circ.setMap(map);

  var circ2 = new google.maps.Circle({
   center: new google.maps.LatLng($pole),
   radius: qcirc,
   map: map,
   strokeColor: "#ff0000",
   strokeWeight: 1,
   fillOpacity: 0
  });

  circ2.setMap(map);

//  var marker = new google.maps.Marker({
//   position: new google.maps.LatLng($midpt),
//   map: map
//  });

}

</script>
</head>
<body onload="initialize()">
  <div id="map_canvas" style="width:100%; height:100%"></div>
</body>
</html>

MARK
;

# TODO: just testing!
write_file($str, "/tmp/temp.html");

die "TESTING";

=item gcmorestats($lat1,$lon1,$lat2,$lon2)

NOTE: extends gcstats (sort of) in bclib.pl

Given two latitude/longitude pairs, return as a hash the following
information:

  - midpoint: the midpoint latitude/longitude

  - pole: the latitude/longitude from which a 1/2-radius circle would
  form the geodesic of equidistant points

  - quad: the latitude/longitude from which a 1/2-radius circle would
  from the great circle path

  - perhaps more later

=cut

sub gcmorestats {
  my($lat1,$lon1,$lat2,$lon2) = @_;
  my(%hash, @temp);

  # TODO: this code could be more efficient in many ways
  # convert to xyz vectors
  my(@v1) = sph2xyz($lon1,$lat1,1,"degrees=1");
  my(@v2) = sph2xyz($lon2,$lat2,1,"degrees=1");

  # TODO: in theory could combine + and -
  # the midpoint xyz (sum and average)
  @temp = vecapply(\@v1, \@v2, "+");
  @temp = map($_/=2, @temp);
  @temp = xyz2sph(@temp, "degrees=1");
  $temp[0] = fmodn($temp[0], 360);
  $hash{midpoint} = [@temp[0..1]];

  # TODO: could combine steps below, but ugly?
  # one of the poles of the great circle
  @temp = vecapply(\@v1, \@v2, "-");
  @temp = xyz2sph(@temp, "degrees=1");
  $temp[0] = fmodn($temp[0], 360);
  $hash{quad} = [@temp[0..1]];

  # one of the poles of the splitting circle
  @temp = crossproduct(@v1,@v2);
  @temp = xyz2sph(@temp, "degrees=1");
  $temp[0] = fmodn($temp[0], 360);
  $hash{pole} = [@temp[0..1]];

  return \%hash;
}

=item antipode($lat,$lon)

Given a latitude/longitude, return its antipode

=cut

sub antipode {
  my($lat,$lon) = @_;
  return (-$lat, fmodn($lon+180,360));
}

=item comments

To find the midpoint of two locations on a sphere, find the linear
midpoint and project to the sphere.

To find the geodesic of equidistant locations, subtract the vectors,
project onto the sphere and draw a circle of radius 1/2 from that
point (sphere radius = 1 assumed)

To find the great circle route, take the cross product of the two
vectors and project to the sphere, draw a circle of radius 1/2

=cut
