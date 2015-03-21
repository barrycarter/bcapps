#!/bin/perl

# Inaccurately (but quickly), find psuedo-psuedo-random lines from a
# large file using seek() without having to read the whole file or
# figure out where linebreaks are

# --n: number of lines wanted (repeats possible), default 1

require "/usr/local/lib/bclib.pl";

defaults("n=1");

# size of file
my($fname) = @ARGV;
$fsize = -s $fname;
my(@rand);

# now gives line in same order they appear in file
for $i (1..$globopts{n}) {push(@rand, int(rand($fsize)));}

open(A, $fname) || die("Can't open $fname, $!");

for $i (sort {$a <=> $b} @rand) {

  debug("BYTE: $i");

  # seek to that position in file
  seek(A, $i, SEEK_SET);

  # read to end of that line
  $eol = <A>;

  # and use the next full line
  $chunk = <A>;

  print $chunk;

}
