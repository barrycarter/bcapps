#!/bin/perl

# Given an existing zoom layer map tile, create a higher level zoom
# tile by cropping the original tile, writing the cropped version to a
# file, and returning it

# TODO: could this be done client side?

=item crop_and_reproject($hashref)

Given zoom, a zoomlevel for which tiles already exist, create the
z/x/y tile where z> zoom, and return it

This version works for equirectangular tiles, not Mercator tiles

=cut

require "/usr/local/lib/bclib.pl";

sub crop_and_reproject {

  my($hashref) = @_;

  my($factor) = 2**($hashref->{z}-$hashref->{zoom});

  my(%ret);

  debug("FACTOR: $factor");

  for $i ("x", "y") {
    for $j (0, 1) {

      my($val) = ($hashref->{$i}+$j)/$factor;

      # note: these should all fall in the same tile
      $ret{tile}{$i}{$j} = floor($val);
      $ret{pixel}{$i}{$j} = floor(256*($val - $ret{tile}{$i}{$j}));
    }
  }

  $ret{tilenum} = $ret{tile}{y}{0}*2**($hashref->{zoom}) + $ret{tile}{x}{0};

  debug(var_dump("RET", \%ret));

  # convert z/x/y to zoom/x/y


  my($tx) = $hashref->{x}*(2**($hashref->{zoom}-$hashref->{z}));
  my($ty) = $hashref->{y}*(2**($hashref->{zoom}-$hashref->{z}));
  debug("TX: $tx, TY: $ty");
}

crop_and_reproject(str2hashref("zoom=5&z=10&x=282&y=432"));

=item comments

why does 282, 432 -> 8, 13 -> 360 ?

360 = 11 * 32 + 8




=cut
