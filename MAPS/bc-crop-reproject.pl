#!/bin/perl

# Given an existing zoom layer map tile, create a higher level zoom
# tile by cropping the original tile, writing the cropped version to a
# file, and returning it

# TODO: could this be done client side?

# TODO: if I *am* going to this server side, might as well send the
# image and make it transparent to end user if its a file or a
# reprojection

=item crop_and_reproject($hashref)

Given zoom, a zoomlevel for which tiles already exist, create the
z/x/y tile where z> zoom, and return it

This version works for equirectangular tiles, not Mercator tiles

height and width must be provided (not necessarily 256x256)

=cut

require "/usr/local/lib/bclib.pl";

sub crop_and_reproject {

  my($hashref) = @_;

  # this is ugly, I may be overfocused on looping
  $hashref->{dim}{x} = $hashref->{width};
  $hashref->{dim}{y} = $hashref->{height};

  my($factor) = 2**($hashref->{z}-$hashref->{zoom});

  my(%ret);

  debug("FACTOR: $factor");

  for $i ("x", "y") {
    for $j (0, 1) {

      my($val) = ($hashref->{$i}+$j)/$factor;

      # note: these should all fall in the same tile
      debug("VAL ($i,$j): $val");
      $ret{tile}{$i}{$j} = floor($val);
      $ret{pixel}{$i}{$j} = floor($hashref->{dim}{$i}*($val - $ret{tile}{$i}{$j}));
    }
  }

  $ret{tilenum} = $ret{tile}{y}{0}*2**($hashref->{zoom}) + $ret{tile}{x}{0};

  debug(var_dump("RET", \%ret));

  # convert z/x/y to zoom/x/y


  my($tx) = $hashref->{x}*(2**($hashref->{zoom}-$hashref->{z}));
  my($ty) = $hashref->{y}*(2**($hashref->{zoom}-$hashref->{z}));
  debug("TX: $tx, TY: $ty");
}

$lonw = -81.21;
$latn = 25.06;
$z = 6;

$x = ($lonw+180)/360*2**$z;
$y = (90-$latn)/180*2**$z;

debug("X: $x, Y: $y");

crop_and_reproject(str2hashref("zoom=5&z=$z&x=17&y=23&width=1350&height=675"));
