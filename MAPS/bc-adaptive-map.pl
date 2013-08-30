#!/bin/perl

# Adaptively create a projected map of the world, using deeper slippy
# tiles where needed

require "/usr/local/lib/bclib.pl";
use Math::Polygon::Calc;
chdir(tmpdir());
slippy2proj(19,17,5,"ortho");

=item slippy2proj($x,$y,$z,$proj)

Returns the projections of several points of a slippy tile under $proj

=cut

sub slippy2proj {
  my($x,$y,$z,$proj) = @_;
  my(@coords);
  my(@coordpairs);
  my(%trans);
  # the order here is nw, sw, ne, se I think!
  for $i (0,128,256) {
    for $j (0,128,256) {
      # this separates lon lat with space and puts them in right order
      # <h>also demonstrates unnecessarily functional programming!</h>
      push(@coords, join(" ",reverse(slippy2latlon($x,$y,$z,$i,$j))));
      debug("IJ: $i,$j");
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

  my(@poly) = ($trans{"0,0"},$trans{"256,0"},$trans{"256,256"},$trans{"0,256"},$trans{"0,0"});
  debug("POLY",@poly);
  debug(polygon_area(@poly));
  debug(polygon_bbox(@poly));

}
