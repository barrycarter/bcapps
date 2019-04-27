#!/bin/perl

# Given an existing zoom layer map tile, create a higher level zoom
# tile by cropping the original tile, writing the cropped version to a
# file, and returning it

# TODO: could this be done client side?

# TODO: if I *am* going to this server side, might as well send the
# image and make it transparent to end user if its a file or a
# reprojection

# TODO: could make this more efficient by letting leaflet reproject
# for certain zoom levels and only reproject here if zoom level is too
# high for leaflet

# TODO: could look at and fix leaflet reprojection code

# TODO: sanitize QUERY_STRING and indiv elements

=item crop_and_reproject($hashref)

Given zoom, a zoomlevel for which tiles already exist, create the
z/x/y tile where z > zoom, and return it

This version works for equirectangular tiles, not Mercator tiles

height and width must be provided (not necessarily 256x256)

=cut

require "/usr/local/lib/bclib.pl";

sub crop_and_reproject {

  my($hashref) = @_;
  my(%ret);

  my($factor) = 2**($hashref->{z}-$hashref->{zoom});
  debug("FACTOR: $factor");

  # find the zoom level tile corresponding to this z level tile

  my($west) = $hashref->{x}/$factor;
  my($xtile) = floor($west);

  # pixel range for x
  my($xpw) = ($west-$xtile)*$hashref->{width};
  my($xpe) = $xpw + $hashref->{width}/$factor;

  debug("X: $xpw - $xpe");

  my($w, $e) = ($hashref->{x}/$factor, ($hashref->{x}+1)/$factor);
  my($n, $s) = ($hashref->{y}/$factor, ($hashref->{y}+1)/$factor);

  # $e may be one number higher due if it hits a tile edge, so use $w
  
  my($tx) = floor($w);
  



  debug("$n $e $s $w");
}

$lonw = -81.21;
$latn = 25.06;
$z = 6;

$x = ($lonw+180)/360*2**$z;
$y = (90-$latn)/180*2**$z;

debug("X: $x, Y: $y");

crop_and_reproject(str2hashref("zoom=5&z=$z&x=17&y=23&width=1350&height=675"));
