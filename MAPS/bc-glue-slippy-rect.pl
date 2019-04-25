#!/bin/perl

# Glues level 8 slippy tiles so they are equirectangular (and then
# repeats the process until I have equirectangular tiles up to level
# 0; for levels 8 and below, slippy tiles are nearly equirectangular
# already

require "/usr/local/lib/bclib.pl";

my(@lat);

for $i (0..255) {

  # note the x value doesn't affect latitude
  my($lat, $lon) = slippy2latlon(0, $i, 8);

  push(@lats, $lat);
}

my(@diffs) = @{list_diff(\@lats)};

debug(@diffs);

# TODO: add this to bclib.pl

sub list_diff {

  my($listref) = @_;
  my(@list) = @$listref;
  my(@ret);

  for ($i=0; $i < $#list; $i++) {
    $ret[$i] = $list[$i+1] - $list[$i];
  }

  return \@ret;
}


