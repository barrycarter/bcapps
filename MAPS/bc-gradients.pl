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

  # this is the start of the gradient
  my(@rgb) = @c1;

  # this is the "perfect" gradient value (used below)
  my(@pfc) = @c1;

  my(@diff, $frac);

  # ramp from 0 to 1 in steps of 1/$dist

  for $i (0..$dist) {

    $frac = $i/$dist;

    # find the perfect rgb value and diff from current rgb value
    for $j (0..2) {
      $pfc[$j] = $c1[$j] + $frac*($c2[$j]-$c1[$j]);
      $diff[$j] = abs($pfc[$j] - $rgb[$j]);
    }

    debug("DIFF", @diff);


    # this is a very dumb way to find the max, but, since there are
    # only 3 elts, it might be more efficient; it also allows
    # consistent breaks between ties, assuming floating point math is
    # consistent

    if ($diff[0] >= $diff[1] && $diff[0] >= $diff[2]) {
      $rgb[0]++;
    } elsif ($diff[1] >= $diff[0] && $diff[1] >= $diff[2]) {
      $rgb[1]++;
    } elsif ($diff[2] >= $diff[0] && $diff[2] >= $diff[1]) {
      $rgb[2]++;
    } else {
      die "BAD THING HAS HAPPENED";
    }
  


#    debug("PFC", @pfc);

  }


  debug("DIST: $dist");

  debug(@c1, @c2);
}

# TODO: doc or something, find linear between 2 numbers at p

sub linear {
  my($x, $y, $p) = @_;
  return $x + $p*($y-$x);
}

