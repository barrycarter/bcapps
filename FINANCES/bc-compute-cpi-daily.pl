#!/bin/perl

# simple script that uses inflation.txt to determine value of $1 daily
# inflation adjusted between two given stardates on command line

require "/usr/local/lib/bclib.pl";

my($start,$end) = @ARGV;

# read in the data

my($data) = read_file("$bclib{githome}/FINANCES/inflation.txt");

my(%cpi);

for $i (split(/\n/, $data)) {

  my(@data) = csv($i);

  # this sets cpi(year) to the entire array, including the year
  # itself, but thats ok because I want January to be the [1] element,
  # not the [0] element

  $cpi{$data[0]} = \@data;

}

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

  debug("YEAR: $year, MONTH: $month");

  debug("I: $i");
}

debug("TOTAL $total");
