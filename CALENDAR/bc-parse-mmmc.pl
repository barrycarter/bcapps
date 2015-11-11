#!/bin/perl

# parses mmmc.gnumeric into meetup API format

# date formats:

# MTRF1100-1300: weekdays, start time to (optional) end time
# 20151117:1000-1100: "stardate", start time to (optional) end time
# 13F1145-1330: first and third Friday, start time to (optional) end time

require "/usr/local/lib/bclib.pl";

my(@arr) = gnumeric2array("$bclib{githome}/CALENDAR/mmmc.gnumeric");

# the first row is headers
my(@headers) = @{$arr[0]};

# remaining rows

for $i (1..$#arr) {

  # create hash
  my(%hash) = ();
  for $j (0..$#headers) {$hash{$headers[$j]} = $arr[$i][$j];}


  debug("HASH",%hash);

}

# TODO: move this to bclib.pl at some point

sub weekdayAfterDate {
  my($date,$day,$n) = @_;
  my($time) = str2time("$date 12:00:00 UTC");
  # the -3 makes Monday = 1
  my($wday) = ($time/86400-3)%7;
  # add appropriate amount for first weekday after date
  $time += ($day-$wday)%7*86400 + $n*86400*7;
  return strftime("%Y%m%d", gmtime($time));
}




