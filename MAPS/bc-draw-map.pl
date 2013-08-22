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

  # the 4 corners of the slippy tile (in lon/lat format)
  # order here is NW, NE, SW, SE
  my(@corners) = ();
  for $j (0,255) {
    for $k (0,255) {
      my($lat,$lon) = slippy2latlon($x,$y,$z,$k,$j);
      push(@corners, $lon, $lat);
    }
  }

  # TODO: this is inefficient, should actually bundle and do at once
  # (ie, all slippy tiles, not one tile at a time)
  my(%hash) = cs2cs([@corners], "ortho");

  # determine the 4 new coords (and skip if ERR)
  my($err) = 0;
  for $j (keys %hash) {
    for $k (keys %{$hash{$j}}) {
      if ($hash{$j}{$k}{x} eq "ERR" || $hash{$j}{$k}{y} eq "ERR") {$err=1;}
      if ($err) {last;}
    }
    if ($err) {last;}
  }

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

