#!/bin/perl

# this trivial script looks at the n last lines of a file and adds the
# rightmost columns as numbers, a weird thing only I have a purpose
# for

# --n: number of lines (default 20)

# I originally tried to set this up as an alias, but escaping the "$" in an alias when inside a Perl script is difficult

require "/usr/local/lib/bclib.pl";

defaults("n=20");

my($file) = @ARGV;

print "\n";

open(A, "tail -n $globopts{n} $file|");

while (<A>) {

  chomp;

  $count++;

  # if the line ends in a number, add it and print the line
  # things like 5*100 count as numbers

  unless (/([\-\.\d\*]+)$/) {next;}

  my($val) = eval($1);

  $tot += $val;

  print "$tot: $_ ($val) [$count]\n\n";

}

print "Total: $tot\n";

