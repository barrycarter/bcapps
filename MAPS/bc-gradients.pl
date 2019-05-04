#!/bin/perl

# fun with gradients

require "/usr/local/lib/bclib.pl";

longest_gradient(str2hashref("c1=0,0,0&c2=255,255,255"));

# TODO: transparency ramp up and down

# TODO: allow finding of nth element for reverse effect

=item longest_gradient

Find the longest gradient between two colors, which is roughly the
Manhattan distance between the two colors. Hash values:

c1: CSV first color
c2: CSV second color

=cut

sub longest_gradient {

  my($hashref) = @_;

  my(@c1) = csv($hashref->{c1});
  my(@c2) = csv($hashref->{c2});

  my($dist) = 0;

  for $i (0..2) {$dist += abs($c1[$i]-$c2[$i])+1;}

  # ramp from 0 to 1 in steps of 1/$dist
  for ($i = 0; $i <= 1; $i += 1/$dist) {

    debug("I: $i");

    # figure out where each color SHOULD be
#    my($r, $g, $b) = 

  }

  debug("DIST: $dist");

  debug(@c1, @c2);
}

# TODO: doc or something, find linear between 2 numbers at p

sub linear {
  my($x, $y, $p) = @_;
  return $x + $p*($y-$x);
}

