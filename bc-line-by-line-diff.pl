#!/bin/perl

# This is not really a diff program-- it reads lines from two files
# and reports when they are different (ie, if line n is different); it
# does not check whether line x in file 1 matches line y in file 2
# (for example)

require "/usr/local/lib/bclib.pl";

my($f1,$f2) = @ARGV;

open(A,$f1)||die("Can't open $f1, $!");
open(B,$f2)||die("Can't open $f2, $!");

for (;;) {

  # just for fun
  if ($count++%10000==0) {debug("LINE: $count");}

  if (eof(A)) {print "A: end of file\n"; last;}
  if (eof(B)) {print "B: end of file\n"; last;}
  my($a,$b) = (scalar(<A>),scalar(<B>));
  unless ($a eq $b) {print "A: $a\nB: $b\n";}
}



