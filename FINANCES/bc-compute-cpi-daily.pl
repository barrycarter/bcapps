#!/bin/perl

# simple script that uses inflation.txt to determine value of $1 daily
# inflation adjusted between two given unix timestamps on command line

# TODO: this seems really ugly, try to tighten

use 5.010;
require "/usr/local/lib/bclib.pl";

my($start,$end) = @ARGV;

# read in the data

# find 1st full month after start date

my(%start) = %{date2hash($start)};

my($startmonth, $startyear) = ($start{truemonth}+1, $start{fullyear});

if ($startmonth > 12) {$startmonth = 1; $startyear++;}

# find 1st full month before end date

my(%end) = %{date2hash($end)};

my($endmonth, $endyear) = ($end{truemonth}-1, $end{fullyear});

if ($endmonth < 1) {$endmonth = 12; $endyear--;}

# using *100 is a bit of a hack

# months with 30 days as hash

%shortMonth = list2hash(4, 6, 9, 11);

# keep track of total

my($total) = 0;

# we use startmonth/startyear as our iterator variables

while ($startyear*100+$startmonth <= $endyear*100+$endmonth) {

  # number of days

  my($daysInMonth) = 31;

  if ($shortMonth{$startmonth}) {$daysInMonth = 30;}

  # don't need 100/400 year formula, inside 1901-2099

  if ($startmonth == 2) {$daysInMonth = 28 + ($startyear%4?0:1)}

  # add for month

  my($cpi) = getCPI($startyear, $startmonth);

  $total += $daysInMonth*$cpi;

  debug("$startyear / $startmonth/ $daysInMonth / $cpi");

  # iteration step

  if (++$startmonth > 12) {$startyear++; $startmonth = 1;}

}

debug("TOTAL: $total");

# get the CPI for given year/month, overriding with max if NA

sub getCPI {

  my($year, $month) = @_;

  state $cpi, $max;

  # load if undefined

  unless ($cpi) {

    debug("LOADING CPI (should happen at most once)");

    for $i (split(/\n/, read_file("$bclib{githome}/FINANCES/inflation.txt"))) {

      # this sets cpi(year) to the entire array, including the year
      # itself, but thats ok because I want January to be the [1] element,
      # not the [0] element

      my(@data) = csv($i);

      $cpi->{$data[0]} = \@data;

      $max = max($max, @data[1..$#data]);

      debug("MAX SET TO: $max");
    }
  }

  my($retval) = $cpi->{$year}[$month];

  debug("RETVAL: *$retval*");

  if (!blank($retval)) {return $retval;} else {return $max;}

}

sub date2hash {

  my($time) = @_;

  my(%hash);

  my(@l) = localtime($time);
  
  for $i ("sec", "min", "hour", "mday", "mon", "year", "wday", "yday", "isdst") {
    $hash{$i} = shift(@l);
  }

  # add useful
  $hash{fullyear} = $hash{year} + 1900;
  $hash{truemonth} = $hash{mon} + 1;

  return \%hash;
}
