#!/bin/perl

# a rewrite of bc-draw-grid.pl thats more efficient
# convention: "lon,lat" (literal comma) represents a
# longitude/latitude (in that order to keep x,y format)

# note "cs2cs -l" or "cs2cs -lP" to list projecctions

# ortho proj: 6378137 = divisor

require "/usr/local/lib/bclib.pl";

open(A,"|parallel -j 10");

my(@outfiles) = ();

# go through the level n slippy tiles
for $i (glob "/var/cache/OSM/4,*") {
  debug("I: $i");
  # which slippy tile is this?
  $i=~m%/(\d+)\,(\d+)\,(\d+)\.png$%;
  my($z,$x,$y) = ($1,$2,$3);

  # TODO: using floating point numbers to index hashes is bad

  # TODO: this is inefficient, since slippy tiles are mercator
  # (longitude range doesn't change for south/north edges)
  # the 4 corners of the slippy tile (in lon/lat format)
  # order here is NW, NE, SW, SE
  my(@corners) = ();
  for $j (0,255) {
    for $k (0,255) {
      my($lat,$lon) = slippy2latlon($x,$y,$z,$k,$j);
      push(@corners, "$lon,$lat");
      # remember which corner of the slippy tile gave us this lat/lon
      $pixel{"$lon,$lat"} = "$k,$j";
    }
  }

  # TODO: this is inefficient, should actually bundle and do at once
  # (ie, all slippy tiles, not one tile at a time)
  my(%hash) = cs2cs([@corners], "ortho");
#  debug(dump_var("hash",{%hash}));

  # TODO: find a cleaner, more consistent way to do this
  # convert ortho coords to screen coords
  my($error) = 0;
  for $j (keys %hash) {
    if ($hash{$j}{x} eq "ERR" || $hash{$j}{y} eq "ERR") {$error=1; last;}
    $hash{$j}{x} = $hash{$j}{x}/6378137*400+400;
    $hash{$j}{y} = $hash{$j}{y}/6378137*-300+300;
  }
  if ($error) {
    debug("ERROR!");
    $error = 0;
    next;
  }
  
  my(@xs,@ys) = ();
  # determine the 4 new coords (and skip if ERR)
  for $j (keys %hash) {
    # find the bounding box of this slippy tile under projection
    push(@xs, $hash{$j}{x});
    push(@ys, $hash{$j}{y});
  }

  # ignore unmapables
  unless (@xs) {next;}

  # transform coords to start at 0,0 and map to correct corner of slippy tile
  @distort = ();
  for $j (keys %hash) {
    $hash{$j}{x} -= min(@xs);
    $hash{$j}{y} -= min(@ys);
    $hash{$j}{x} = round($hash{$j}{x});
    $hash{$j}{y} = round($hash{$j}{y});
    push(@distort, "$pixel{$j},$hash{$j}{x},$hash{$j}{y}");
  }
  $distort = join(" ",@distort);

  # determine extent
  $xe = round(max(@xs)-min(@xs));
  $ye = round(max(@ys)-min(@ys));

  # create a distorted version of this tile 
  my($cmd) = "convert -mattecolor transparent -extent ${xe}x$ye -background transparent -matte -virtual-pixel transparent -distort Perspective \"$distort\" $i /tmp/bcdg-$x-$y-$z.gif";
  print "CMD: $cmd\n";
  print A "$cmd\n";
  push(@outfiles, "/tmp/bcdg-$x-$y-$z.gif");
}

close(A);

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

$options: [NOT YET IMPLEMENTED]

  fx=f: apply the function f to the x coordinates before returning
  fy=f: apply the function f to the y coordinates before returning
  fz=f: apply the function f to the z coordinates before returning

=cut

sub cs2cs {
  my($listref, $proj, $options) = @_;
  # by default, apply the id function to x,y,z
  my(%opts) = parse_form("fx=id&fy=id&fz=id&$options");
  my(@lonlat) = @{$listref};
  my($str);
  my(%rethash);

  # write data to file
  for $i (@lonlat) {
    $i=~s/,/ /;
    $str .= "$i\n";
  }

  my($tmpfile) = my_tmpfile2();
  write_file($str, $tmpfile);

  # -r since we're doing lonlat, not latlon; oddly, "lonlat" for proj4
  # ALSO requires lat/lon order, bizarre
  my($out,$err,$res) = cache_command("cs2cs -r -E -e 'ERR ERR' +proj=latlon +to +proj=$proj < $tmpfile","age=86400");
  for $i (split(/\n/,$out)) {
    my(@fields) = split(/\s+/,$i);
    # return order here is y/x/z, surprisingly
    $rethash{"$fields[0],$fields[1]"}{y} = $fields[2];
    $rethash{"$fields[0],$fields[1]"}{x} = $fields[3];
    $rethash{"$fields[0],$fields[1]"}{z} = $fields[4];
  }

  return %rethash;
}

