#!/bin/perl

# a rewrite of bc-draw-grid.pl thats more efficient
# convention: longitude then latitude to preserve x,y format

# note "cs2cs -l" or "cs2cs -lP" to list projecctions

# ortho proj: 6378137 = divisor

require "/usr/local/lib/bclib.pl";

# go through the level 5 slippy tiles
for $i (glob "/var/cache/OSM/5,*") {
  # which slippy tile is this?
  $i=~m%/(\d+)\,(\d+)\,(\d+)\.png$%;
  my($z,$x,$y) = ($1,$2,$3);

  # TODO: using floating point numbers to index hashes is bad

  # what latitude/longitude does it represent (NW + SE corners)
  # note slippy2latlon returns lat/lon, not lon/lat
  my($nwlat, $nwlon) = slippy2latlon($x,$y,$z,0,0);
  my($selat, $selon) = slippy2latlon($x,$y,$z,255,255);

  # TODO: this is inefficient, should actually bundle and do at once
  # NOTE: switching order to be lon/lat
  my(%hash) = cs2cs([$nwlon,$nwlat,$selon,$selat], "ortho");

  # if either is error, ignore this slippy tile
  # sufficient to check just x value
  if ($hash{$nwlon}{$nwlat}{x} eq "ERR" || $hash{$selon}{$selat}{x} eq "ERR") {
    next;
  }

  # convert to x/y coords
  ($nwx, $nwy) = ($hash{$nwlon}{$nwlat}{x}/6378137*400+400,
		  $hash{$nwlon}{$nwlat}{y}/6378137*300+300);

  ($sex, $sey) = ($hash{$selon}{$selat}{x}/6378137*400+400,
		  $hash{$selon}{$selat}{y}/6378137*300+300);

  

  debug("$nwx,$nwy to $sex,$sey");

  die "TESTING";

}

%hash = cs2cs([@coords],"ortho");

debug(dump_var("hash",{%hash}));

die "TESTING";

for ($i=-90; $i<=90; $i+=30) {
  for ($j=-180; $j<=180; $j+=30) {
    push(@l,$i,$j);
  }
}

%hash = cs2cs([@l],"ortho");

print << "MARK";
new
size 800,600
setpixel 0,0,0,0,0
MARK
;

for $i (sort keys %hash) {
  for $j (sort keys %{$hash{$i}}) {
    if ($hash{$i}{$j}{x} eq "ERR") {next;}
    my($x,$y) = ($hash{$i}{$j}{x}/6378137,$hash{$i}{$j}{y}/6378137);
    # mapping on to 700x500 for padding
    $x = $x*350+400;
    $y = $y*-250+300;
    print "string 255,255,255,$x,$y,tiny,$i,$j\n";
  }
}

