#!/bin/perl

# attempts to generate random notification ids that are "likely" to be
# in the last 24 hours based on latest observations and assuming
# linear, not exponential growth

# The formula I in my blog entry, is way off, alas

require "/usr/local/lib/bclib.pl";

# benchmarks in MDT

# TODO: use microseconds which quora provides in source, instead of minutes

# 172649658 -> 14 Sep 2016 11:38 AM
# 170359726 -> 3 Sep 2016 1:42 PM

$y2 = str2time("14 Sep 2016 11:38 AM MDT");
$y1 = str2time("3 Sep 2016 1:42 PM");
$x2 = 172649658;
$x1 = 170359726;
my($slope) = ($x2-$x1)/($y2-$y1);

my($time) = time();

debug(($time-$x1)*$slope 


debug

