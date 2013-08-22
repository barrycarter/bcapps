#!/bin/perl

# a rewrite of bc-draw-grid.pl thats more efficient
# convention: "lon,lat" (literal comma) represents a
# longitude/latitude (in that order to keep x,y format)

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
      push(@corners, "$lon, $lat");
    }
  }

  # TODO: this is inefficient, should actually bundle and do at once
  # (ie, all slippy tiles, not one tile at a time)
  debug("CORNERS",@corners);
  my(%hash) = cs2cs([@corners], "ortho");

  debug("HASH",dump_var("hash",{%hash}));
  die "TESTING";

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

=item cs2cs(\@lonlat, $proj, $options)

Given a list of longitude/latitudes (each entry being "lon,lat" as a
literal string with a comma in it), return the mapping of these
longitude/latitudes under cs2cs projection $proj as a hash such that:

$rethash{"$lon,$lat"}{x} = the x coordinate of the transform
$rethash{"$lon,$lat"}{y} = the y coordinate of the transform
$rethash{"$lon,$lat"}{z} = the z coordinate of the transform

A simple wrapper around cs2cs.

$options currently unused

=cut

sub cs2cs {
  my($listref, $proj, $options) = @_;
  my(@lonlat) = @{$listref};
  debug("LONLAT",@lonlat);
  my($str);
  my(%rethash);

  # write data to file
  for $i (@lonlat) {
    $i=~s/,/ /;
    $str .= "$i\n";
  }

  my($tmpfile) = my_tmpfile2();
  write_file($str, $tmpfile);
  debug("STR: $str");
  debug("TMPFILE: $tmpfile");

  # -r since we're doing lonlat, not latlon; oddly, "lonlat" for proj4
  # ALSO requires lat/lon order, bizarre
  my($out,$err,$res) = cache_command("cs2cs -r -E -e 'ERR ERR' +proj=latlon +to +proj=$proj < $tmpfile","age=86400");
  debug("OUT: $out");
  for $i (split(/\n/,$out)) {
    my(@fields) = split(/\s+/,$i);
    $rethash{$fields[0]}{$fields[1]}{x} = $fields[2];
    $rethash{$fields[0]}{$fields[1]}{y} = $fields[3];
    $rethash{$fields[0]}{$fields[1]}{z} = $fields[4];
  }

  return %rethash;
}

