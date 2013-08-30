#!/bin/perl

# Being too lazy to look them up myself, this program estimates the x
# and y ranges for the various cs2cs projections listed by "cs2cs -l"

# TODO: obviously, copying cs2cs() here is wrong

require "/usr/local/lib/bclib.pl";

my($out,$err,$res)=cache_command2("cs2cs -l","age=86400");

# list of lonlat
my(@coords);
for ($i=-180; $i<=180; $i+=10) {
  for ($j=-90; $j<=90; $j+=10) {
    push(@coords,"$i,$j");
  }
}

for $i (split(/\n/,$out)) {
  unless ($i=~s/\s*:.*$//) {next;}
  %res = cs2cs([@coords], $i);
  debug(dump_var("res",{%res}));
  die "TESTING";
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
  my(%iscoord);

  # write data to file
  for $i (@lonlat) {
    $i=~s/,/ /;
    $str .= "$i\n";
  }

  my($tmpfile) = my_tmpfile2();
  write_file($str, $tmpfile);

  my($out,$err,$res) = cache_command("cs2cs -E -e 'ERR ERR' +proj=lonlat +to +proj=$proj < $tmpfile","age=86400");
  for $i (split(/\n/,$out)) {
    debug("I: $i");
    my(@fields) = split(/\s+/,$i);
    $rethash{"$fields[0],$fields[1]"}{x} = $fields[2];
    $rethash{"$fields[0],$fields[1]"}{y} = $fields[3];
    $rethash{"$fields[0],$fields[1]"}{z} = $fields[4];
  }
  return %rethash;
}




