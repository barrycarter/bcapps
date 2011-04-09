#!/bin/perl

# Unusual approach to Voronoi diagram of Earth sphere: cut into 4
# pieces and compare closest point for 4 vertices

# TODO: this program is long and clumsy and can doubtless be improved

require "bclib.pl";

open(A,">/home/barrycarter/BCINFO/sites/TEST/gvorbin.txt");

# latitude and longitude of points
%points = (
 "Albuquerque" => "35.08 -106.66",
 "Paris" => "48.87 2.33",
 "Barrow" => "71.26826 -156.80627",
 "Wellington" => "-41.2833 174.783333",
 "Rio" => "-22.88  -43.28"
);

# primartish colors
%colors = (
 "Albuquerque" => "#ff0000",
 "Paris" => "#00ff00",
 "Barrow" => "#0000ff",
 "Wellington" => "#ffff00",
 "Rio" => "#ff00ff",
 "BORDER" => "#000000"
);

# stop at what gridsize
$minarea = .5;

$nw = bvoronoi(0,90,-180,0);
$ne = bvoronoi(0,90,0,180);
$sw = bvoronoi(-90,0,-180,0);
$se = bvoronoi(-90,0,0,180);

print $nw,$ne,$sw,$se;

for $i (split("\n","$nw\n$ne\n$sw\n$se")) {
  # create google filled box
  my($latmin, $latmax, $lonmin, $lonmax, $closest) = split(/\s+/, $i);

  # build up the coords
  print A << "MARK";

var myCoords = [
 new google.maps.LatLng($latmin, $lonmin),
 new google.maps.LatLng($latmin, $lonmax),
 new google.maps.LatLng($latmax, $lonmax),
 new google.maps.LatLng($latmax, $lonmin),
 new google.maps.LatLng($latmin, $lonmin)
];

myPoly = new google.maps.Polygon({
 paths: myCoords,
 strokeColor: "$colors{$closest}",
 strokeOpacity: 1,
 strokeWeight: 0,
 fillColor: "$colors{$closest}",
 fillOpacity: 0.5
});

myPoly.setMap(map);

MARK
;

}

# workhorse function: given a "square" (on an equiangular map),
# determine the closest point of 4 vertices; if same, return square
# and point; otherwise, break square into 4 squares and recurse

sub bvoronoi {
  # Using %points as global is ugly
  my($latmin, $latmax, $lonmin, $lonmax) = @_;
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
      # TODO: should abort loop if we already have two different closest points
      $closest{$minpoint} = 1;
    }
  }

  # if there's just one point closest to all four corners, return it
  my(@keys) = keys %closest;

  # if @keys has length 1, return it
  unless ($#keys) {
    return "$latmin $latmax $lonmin $lonmax $keys[0]";
  }

  # if we've hit a border point, return it (area too small)
  my($area) = ($latmax-$latmin)*($lonmax-$lonmin);

  if ($area <= $minarea) {
    return "$latmin $latmax $lonmin $lonmax BORDER";
  }

  # split square and recurse
  my($latmid) = ($latmax+$latmin)/2.;
  my($lonmid) = ($lonmax+$lonmin)/2.;

  my(@sub) = ();
  push(@sub, bvoronoi($latmin, $latmid, $lonmin, $lonmid));
  push(@sub, bvoronoi($latmid, $latmax, $lonmin, $lonmid));
  push(@sub, bvoronoi($latmin, $latmid, $lonmid, $lonmax));
  push(@sub, bvoronoi($latmid, $latmax, $lonmid, $lonmax));

  return join("\n", @sub);
}
