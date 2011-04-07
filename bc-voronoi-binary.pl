#!/bin/perl

# Unusual approach to Voronoi diagram of Earth sphere: cut into 4
# pieces and compare closest point for 4 vertices

require "bclib.pl";

# latitude and longitude of points
%points = (
 "Albuquerque" => "35.08 -106.66",
 "Paris" => "48.87 2.33"
# "Barrow" => "71.26826 -156.80627",
# "Wellington" => "-41.2833 174.783333"
# "Rio de Janeiro" => "-22.88  -43.28"
);

debug(bvoronoi(0,90,-180,0));

# primary function: given a "square" (on an equiangular map),
# determine the closest point of 4 vertices; if same, return square
# and point; otherwise, break square into 4 squares and recurse

sub bvoronoi {
  # Using %points as global is ugly
  my($latmin, $latmax, $lonmin, $lonmax) = @_;
  debug("bvoronoi $latmin, $latmax, $lonmin, $lonmax");
  my(%res);
  my($mindist, $dist, %closest);

  # compute distance to each %points for each corner
  # TODO: this is wildly inefficient, since I just need relative
  # distance, not exact!
  for $lat ($latmin,$latmax) {
    for $lon ($lonmin,$lonmax) {
      # TODO: has to be easier way to do this?
      $mindist = 0; $dist= 0;
      for $point (keys %points) {
	my($plat,$plon) = split(/\s+/, $points{$point});
	$dist = gcdist($lat, $lon, $plat, $plon);
	if ($dist < $mindist || !$mindist) {
	  $mindist = $dist;
	  $minpoint = $point;
	}
      }
      # this point is closest to one vertex of the square
      # should abort loop if we already have two closest points
      $closest{$minpoint} = 1;
    }
  }

  # if there's just one point closest to all four corners, return it
  my(@keys) = keys %closest;

  unless ($#keys) {
    return "$latmin $latmax $lonmin $lonmax $keys[0]";
  }

  # if we've hit a border point, return it
  my($area) = ($latmax-$latmin)*($lonmax-$lonmin);
  debug("AREA: $area");

  if ($area <= 1) {
    return "$latmin $latmax $lonmin $lonmax BORDER";
  }

  # split square and recurse
  my($latmid) = ($latmax+$latmin)/2.;
  my($lonmid) = ($lonmax+$lonmin)/2.;
  debug("AL: $latmid $lonmid");

  my(@sub) = ();
  push(@sub, bvoronoi($latmin, $latmid, $lonmin, $lonmid));
  push(@sub, bvoronoi($latmid, $latmax, $lonmin, $lonmid));
  push(@sub, bvoronoi($latmin, $latmid, $lonmid, $lonmax));
  push(@sub, bvoronoi($latmid, $latmax, $lonmid, $lonmax));

  return join("\n", @sub);
}
