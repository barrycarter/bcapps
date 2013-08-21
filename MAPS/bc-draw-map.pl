#!/bin/perl

# a rewrite of bc-draw-grid.pl thats more efficient
# convention: longitude then latitude to preserve x,y format

# note "cs2cs -l" or "cs2cs -lP" to list projecctions

require "/usr/local/lib/bclib.pl";

for ($i=-90; $i<=90; $i+=30) {
  for ($j=-180; $j<=180; $j+=30) {
    push(@l,$i,$j);
  }
}

%hash = cs2cs([@l],"ortho");

debug($hash{60}{0}{y});

=item cs2cs(\@lonlat, $proj, $options)

Given a list of longitude/latitudes (simple list of even length),
return the mapping of these longitude/latitudes under cs2cs projection
$proj as a hash such that:

$rethash{$lon}{$lat}{x} = the x coordinate of the transform
$rethash{$lon}{$lat}{y} = the y coordinate of the transform
$rethash{$lon}{$lat}{z} = the z coordinate of the transform

A simple wrapper around cs2cs.

$options currently unused

=cut

sub cs2cs {
  my($listref, $proj, $options) = @_;
  my(@lonlat) = @{$listref};
  my($str);
  my(%rethash);

  # write data to file
  while (@lonlat) {
    # TODO: this may break if right side eval isn't in order
    my($lon,$lat) = (shift(@lonlat),shift(@lonlat));
    $str .= "$lon $lat\n";
  }

  my($tmpfile) = my_tmpfile2();
  write_file($str, $tmpfile);
  debug("TMPFILE: $tmpfile");

  # -r since we're doing lonlat, not latlon; oddly, "lonlat" for proj4
  # ALSO requires lat/lon order, bizarre
  my($out,$err,$res) = cache_command("cs2cs -r -E -e 'ERR ERR' +proj=latlon +to +proj=$proj < $tmpfile","age=86400");
  for $i (split(/\n/,$out)) {
    my(@fields) = split(/\s+/,$i);
    $rethash{$fields[0]}{$fields[1]}{x} = $fields[2];
    $rethash{$fields[0]}{$fields[1]}{y} = $fields[3];
    $rethash{$fields[0]}{$fields[1]}{z} = $fields[4];
  }

  return %rethash;
}

