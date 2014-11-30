#!/bin/perl

# trivial script that lets me note asteroid masses in header.430_572
# as names, not just numbers

# Planet.csv.gz courtesy dbpedia

require "/usr/local/lib/bclib.pl";

open(A,"zcat $bclib{githome}/ASTRO/Planet.csv.gz|");

while (<A>) {
  @vals = csv($_);

  # name is last value (but there's a blank at the end)
  my($name) = $vals[-2];

  # asteroids only (this is imperfect but close)
  unless ($name=~/^(\d+)\s+(.*)$/) {next;}
  my($num, $name) = ($1,$2);

  # map number (as 4 digits) to name
  $name{sprintf("MA%0.4d",$num)} = "$num $name";
}

# read a tempfile I created to insert asteroidal masses (it's the
# output of `bc-header-values.pl | fgrep MA`)

for $i (split(/\n/,read_file("/tmp/asts.txt"))) {
  unless ($i=~/^(MA\d+):/) {next;}

  print "$i mass of $name{$1}\n";
}


