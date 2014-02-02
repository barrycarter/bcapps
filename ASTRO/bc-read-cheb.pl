#!/bin/perl

# reads the Chebyshev coefficients from ascp1950.430.bz2

require "/usr/local/lib/bclib.pl";

# list of planets with hardcoded coefficient numbers/etc
# TODO: don't hardcode, use header.430_572

@planets = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "whocares:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2");

open(A,"bzcat /home/barrycarter/BCGIT/ASTRO/ascp1950.430.bz2|");
# only the year 2014 (for now), which starts at...
read(A, $disc, 26873*768);

# will end with explicit exit
for (;;) {
  my($buf);

  # file is very well formatted, each 26873 bytes is one section
  read(A, $buf, 26873);
  # split into numbers
  my(@nums) = split(/\s+/s, $buf);
  # convert to Perl
  map(s/^(.*?)D(.*)$/$1*10**$2/e, @nums);

  # first four: section number, number of data points, julian start, julia end
  my($bl, $sn, $nd, $js, $je) = splice(@nums,0,5);
  debug("$js - $je");
  # length of interval
  my($in) = $je-$js;

  # and now the planet list
  for $i (@planets) {
    # I don't actually use $spos, since I'm splicing
    my($pl, $spos, $ncoeff, $sects) = split(/:/, $i);
    # days per interval
    my($days) = $in/$sects;
    # loop through each section
    for $j (1..$sects) {
      for $k ("x","y","z") {
	@coeffs = splice(@nums,0,$ncoeff);
	debug("J: $j, K: $k, COEFFS",@coeffs);
      }
    }
  }
}

