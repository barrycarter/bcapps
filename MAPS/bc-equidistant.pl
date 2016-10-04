#!/bin/perl

# testbed for trivial map functions

require "/usr/local/lib/bclib.pl";

# debug(antipode(5,10));

gcmorestats(34.0522226126327, -118.243667974691, 32.7153237292363,
-117.157244512871);

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
  my(%hash);
  debug("GOT",@_);

  # convert to xyz vectors
  my(@v1) = sph2xyz($lon1,$lat1,1,"degrees=1");
  my(@v2) = sph2xyz($lon2,$lat2,1,"degrees=1");

  # the midpoint xyz (sum and average)
  my(@mid) = vecapply(\@v1, \@v2, "+");
  @mid = map($_/=2, @mid);
  # re-using @mid here is probably bad
  @mid = xyz2sph(@mid, "degrees=1");
  $mid[0] = fmodn($mid[0], 360);
  $mid[1] = fmodn($mid[1], 180);
  $hash{midpoint} = [@mid[0..1]];

  # the pole of the splitting circle

  debug(%hash);
  debug("BETA",@mid);
#  debug("ALPHA", @mid);
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
