#!/bin/perl

# attempts to generate random notification ids that are "likely" to be
# in the last 24 hours based on latest observations and assuming
# linear, not exponential growth

# TODO: generate n URLs not 5 exactly
# TODO: allow user to set how many days old (eg, 1-5 days)
# TODO: if possible, self-adjust formula

# The formula I in my blog entry, is way off, alas

require "/usr/local/lib/bclib.pl";

# benchmarks in MDT

# TODO: use microseconds which quora provides in source, instead of minutes

# 172649658 -> 14 Sep 2016 11:38 AM
# 170359726 -> 3 Sep 2016 1:42 PM

$x2 = str2time("14 Sep 2016 11:38 AM MDT");
$x1 = str2time("3 Sep 2016 1:42 PM");
$y2 = 172649658;
$y1 = 170359726;

my($slope) = ($y2-$y1)/($x2-$x1);

my($time) = time();

my($hwm) = int(($time-$x1)*$slope + $y1);
my($lwm) = int($hwm-$slope*86400);

for $i (0..11) {

  my($rand) = int($lwm+rand()*($hwm-$lwm));

  # horrible programming here to insure low and high water marks always printed
  if ($i==0) {$rand = $lwm;}
  if ($i==1) {$rand = $hwm;}

  print "https://www.quora.com/log/revision/$rand\n";

}

# NOTE: can pipe output to bc-open-urls.pl if desired
