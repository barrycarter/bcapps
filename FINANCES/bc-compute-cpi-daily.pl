#!/bin/perl

# simple script that uses inflation.txt to determine value of $1 daily
# inflation adjusted between two given unix timestamps on command line

# TODO: this seems really ugly, try to tighten

require "/usr/local/lib/bclib.pl";

my($start,$end) = @ARGV;

# read in the data

my($data) = read_file("$bclib{githome}/FINANCES/inflation.txt");

my(%cpi);

# store max cpi and use for CPI not yet released

my($max);

for $i (split(/\n/, $data)) {

  my(@data) = csv($i);

  # this sets cpi(year) to the entire array, including the year
  # itself, but thats ok because I want January to be the [1] element,
  # not the [0] element

  $cpi{$data[0]} = \@data;

  $max = max($max, @data[1..$#data]);

}

# find 1st full month after start date

my(%start) = %{date2hash($start)};

my($nextmonth, $year) = ($start{truemonth}+1, $start{fullyear});

if ($nextmonth > 12) {$nextmonth = 1; $year++;}

my($next) = str2time("$year-$nextmonth-01 00:00:00");

# find 1st full month before end date

my(%end) = %{date2hash($end)};

my($prevmonth, $year) = ($end{truemonth}-1, $end{fullyear});

if ($prevmonth < 1) {$prevmonth = 12; $year--;}

my($prev) = str2time("$year-$prevmonth-01 00:00:00");


debug("NEXT: $prev to $next");

debug(keys %start);

debug("MAX: $max");

die "TESTING";

debug(%cpi);

# convert dates to Unix timestamps

my($tstart) = datestar($start);
my($tend) = datestar($end);

debug("T: $tstart, $tend");

# TODO: error checking

# TODO: this is hideous, no need to go day by day should use multiplication

my($total);

for ($i = $tstart; $i <= $tend; $i += 86400) {

  # TODO: converting back and forth between stardate seems odd

  my($date) = stardate($i);

  # find year and month for CPI

  $date=~m%^(\d{4})(\d{2})%;

  my($year, $month) = ($1, $2);

  $total += $cpi{$year}[$month];

  debug("CPI: $cpi{$year}[$month]");

  debug("YEAR: $year, MONTH: $month");

  debug("I: $i");
}

debug("TOTAL $total");

# given a Unix timestamp, return localtime as hash

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
