#!/bin/perl

# parses all-retrogrades.txt.bz2: which planets in retrograde at given time

require "/usr/local/lib/bclib.pl";

%short = ("MERCURY" => 1, "VENUS" => 2, "MARS" => 4, "JUPITER" => 5,
	  "SATURN" => 6, "URANUS" => 7, "NEPTUNE" => 8, "PLUTO" => 9);

# which planets are currently in retrograde

my(%retro);

open(A, "bzcat all-retrogrades.txt.bz2|");

while (<A>) {

  if (rand() < 10**-5) {debug("STATUS: $_");}

  my($era, $date, $time, $planet, $dir, $retro, $time) = split(/\s+/, $_);

  if ($dir eq "STARTS") {
    $retro{$short{$planet}} = 1;
  } elsif ($dir eq "ENDS") {
    delete $retro{$short{$planet}};
  } else {
    die ("BAD LINE: $_");
  }

  print $time," ",join("", sort keys %retro),"\n";
}

