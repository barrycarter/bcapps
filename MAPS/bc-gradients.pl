#!/bin/perl

# fun with gradients

require "/usr/local/lib/bclib.pl";

# longest_gradient(str2hashref("c1=0,0,0&c2=255,255,255"));

# qgis spectral gradient part 1
longest_gradient(str2hashref("c1=43,131,186&c2=171,221,164"));

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
  my(@dir);

  # this calculates the distance between the colors and the per-color direction

  for $i (0..2) {
    my($temp) = $c2[$i] - $c1[$i];
    $dist += abs($temp)+1;
    $dir[$i] = signum($temp);
  }

  # this is the start of the gradient
  my(@rgb) = @c1;

  # this is the "perfect" gradient value (used below)
  my(@pfc) = @c1;

  my(@diff, $frac, $max);

  # ramp from 0 to 1 in steps of 1/$dist

  # TODO: this allows colors past c2 yuck

  for $i (0..$dist) {

    $frac = $i/$dist;

    debug("FRAC: $frac");

    # keep track of which diff is maximal
    $max = 0;

    # find the perfect rgb value and diff from current rgb value
    for $j (0..2) {
      $pfc[$j] = $c1[$j] + $frac*($c2[$j]-$c1[$j]);

      # this determines whether the current color is lagging or leading
      $diff[$j] = ($pfc[$j] - $rgb[$j])*$dir[$j];

      if ($diff[$j] > $diff[$max]) {$max = $j;}
    }

    debug("RGB", @rgb, "PFC", @pfc);

    # increment the one with the biggest diff
    $rgb[$max] += $dir[$max];

    # and print the color
    print join(",",@rgb),"\n";

  }
}

# TODO: doc or something, find linear between 2 numbers at p

sub linear {
  my($x, $y, $p) = @_;
  return $x + $p*($y-$x);
}

