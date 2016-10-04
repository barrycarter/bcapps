#!/bin/perl

# testbed for trivial map functions

require "/usr/local/lib/bclib.pl";

debug(antipode(5,10));




=item polepos($lat1,$lon1,$lat2,$lon2)

Given two latitude/longitude pairs, treat the geodesic that is
equidistant from them as an "equator" and find the "North Pole"

=cut

sub polepos {
  my($lat1,$lon1,$lat2,$lon2) = @_;

  # entirely from Mathematica, see bc-equidistant.m
  




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
