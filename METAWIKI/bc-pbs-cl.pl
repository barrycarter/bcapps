#!/bin/perl

# I am using feh's caption feature to rapidly list characters
# appearing in each Pearls Before Swine strip; this script parses
# those caption files and outputs semantic triples to pbs-cl.txt

require "/usr/local/lib/bclib.pl";

# the conversions (capital letters = mention, but no appearance)
%full = ("p" => "[[character::Pig]]",
	 "r" => "[[character::Rat]]",
	 "g" => "[[character::Goat]]",
	 "z" => "[[character::Zebra]]",
	 "P" => "[[mention::Pig]]"
	 );

open(A,">/home/barrycarter/BCGIT/METAWIKI/pbs-cl.txt");

# where these special captions are (not in the main PBS directory!)
for $i (glob "/mnt/extdrive/GOCOMICS/pearlsbeforeswine/CHARLIST/*.txt") {

  # characters appearing in this strip
  @data = split(//,read_file($i));

  # convert to full form
  for $j (@data) {$j = $full{$j};}

  # date of this strip
  $i=~/(\d{4}-\d{2}-\d{2})/ || warn("BAD FILE: $i");
  $date = $1;

  # and print
  print A join(" ",$date,@data),"\n";
}

close(A);
