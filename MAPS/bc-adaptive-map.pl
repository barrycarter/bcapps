#!/bin/perl

# Adaptively create a projected map of the world, using deeper slippy
# tiles where needed

require "/usr/local/lib/bclib.pl";
use Math::Polygon::Calc;
chdir(tmpdir());
$z = 2;
$proj = "ortho";

# TODO: this will not always work, especially for projections with options
my($out,$err,$res) = cache_command2("fgrep $proj /home/barrycarter/BCGIT/MAPS/projranges.txt");
my(@f) = split(/\s+/,$out);
my($xmin, $xmax, $ymin, $ymax) = @f[2,3,5,6];
my($projarea) = ($xmax-$xmin)*($ymax-$ymin);
debug("AREA: $projarea");
die "TESTING";

for $i (0..2**$z-1) {
  for $j (0..2**$z-1) {
    %res = slippy2proj($i,$j,$z,"ortho");
    debug("IJ: $i,$j -> $res{distortion}");
  }
}

# recursive routine that attempts to map a slippy tile, but handles
# errors and distortions

sub map_tile {
  my($x,$y,$z,$proj) = @_;
  my(%res) = slippy2proj($i,$j,$z,"ortho");
}

=item slippy2proj($x,$y,$z,$proj)

Returns the projections of several points of a slippy tile under $proj

=cut

sub slippy2proj {
  my($x,$y,$z,$proj) = @_;
  my(@coords);
  my(@coordpairs);
  my(%trans);
  # the order here is: nw, n, ne, w, center, e, sw, s, se
  for $i (0,128,256) {
    for $j (0,128,256) {
      # this separates lon lat with space and puts them in right order
      # <h>also demonstrates unnecessarily functional programming!</h>
      push(@coords, join(" ",reverse(slippy2latlon($x,$y,$z,$i,$j))));
      push(@coordpair, "$i,$j");
    }
  }

  my($coords) = join("\n",@coords);
  debug("COORDS: $coords</coords>");
  write_file("$coords\n", "coords");

  # below cannot be cached!
  my($out,$err,$res) = cache_command2("cs2cs -E -e 'ERR ERR' +proj=lonlat +to +proj=$proj < coords");
  debug("OUT: $out");

  for $i (split(/\n/,$out)) {
    debug("I: $i");
    my(@fields) = split(/\s+/,$i);
    # fields[2] and [3] are the unscaled x/y coords
    # get the coordpair matching these values
    my($pair) = shift(@coordpair);
    $trans{$pair} = [$fields[2],$fields[3]];
  }

  # compare the polygon area to its bbox to determine "rectangularity"
  my(@poly) = ($trans{"0,0"},$trans{"256,0"},$trans{"256,256"},$trans{"0,256"},$trans{"0,0"});
  my($area) = polygon_area(@poly);
  my ($xmin, $ymin, $xmax, $ymax) = polygon_bbox(@poly);
  my($bbarea) = ($ymax-$ymin)*($xmax-$xmin);
  $trans{distortion} = $area/$bbarea;
  return %trans;
}
