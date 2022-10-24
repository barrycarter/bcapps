#!/bin/perl

# simple script that uses inflation.txt to determine value of $1 daily
# inflation adjusted between two given unix timestamps on command line

# TODO: this seems really ugly, try to tighten

use 5.010;
require "/usr/local/lib/bclib.pl";

my($start,$end) = @ARGV;



# THIS IS A HACK WAY OF DOING THINGS AS A TEST SIGH

my(%hackstart) = %{date2hash($start)};

my($hackbase) = getCPI($hackstart{fullyear}, $hackstart{truemonth});

debug("BASE: $hackbase");

my($hacktotal);

for ($hacktime = $start; $hacktime <= $end; $hacktime += 86400) {

  my(%hash) = %{date2hash($hacktime)};

  $hacktotal += getCPI($hash{fullyear}, $hash{truemonth})/$hackbase;

  debug("HACK: $hash{fullyear}-$hash{truemonth}-$hash{mday}: $hacktotal");

}

print "HACKTOTAL: $hacktotal\n";

# find 1st full month after start date

my(%start) = %{date2hash($start)};

# before we increment startmonth, find total CPI + base value

my($basecpi) = getCPI($start{fullyear}, $start{truemonth});

my($days) = daysInMonth($start{fullyear}, $start{truemonth}) - $start{mday} + 1;

# initalize total

my($total) = $days*$basecpi;

debug("ALPHA: $basecpi / $start{fullyear} / $start{truemonth} / $start{mday} / $days / $total");

my($startmonth, $startyear) = ($start{truemonth}+1, $start{fullyear});

if ($startmonth > 12) {$startmonth = 1; $startyear++;}

# find 1st full month before end date

my(%end) = %{date2hash($end)};

# CPI for end month itself

$total += $end{mday}*getCPI($end{fullyear}, $end{truemonth});

my($endmonth, $endyear) = ($end{truemonth}-1, $end{fullyear});

if ($endmonth < 1) {$endmonth = 12; $endyear--;}

# we use startmonth/startyear as our iterator variables

# using *100 is a bit of a hack

while ($startyear*100+$startmonth <= $endyear*100+$endmonth) {

  # number of days

  my($daysInMonth) = daysInMonth($startyear, $startmonth);

  # add for month

  my($cpi) = getCPI($startyear, $startmonth);

  $total += $daysInMonth*$cpi;

  debug("$startyear / $startmonth/ $daysInMonth / $cpi");

  # iteration step

  if (++$startmonth > 12) {$startyear++; $startmonth = 1;}

}

debug("TOTAL: $total/$basecpi");

$total /= $basecpi;

print "TOTAL: $total\n";

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

#      debug("MAX SET TO: $max");
    }
  }

  my($retval) = $cpi->{$year}[$month];

  debug("RETVAL: $year $month -> *$retval*");

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

sub daysInMonth {

  my($year, $month) = @_;

  if ($month=~/^(4|6|9|11)$/) {return 30;}

  if ($month=~/^(1|3|5|7|8|10|12)$/) {return 31;}

  unless ($month eq "2") {
    warn("INVALID MONTH");
    return;
  }

  if (($year%4 == 0 && $year%100 != 0)|| $year%400 == 0) {return 29;}

  return 28;
}
