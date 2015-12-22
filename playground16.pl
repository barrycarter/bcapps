#!/bin/perl

# hopefully simpler way to access shell (most webpages I've read say
# this shouldn't work)

require "/usr/local/lib/bclib.pl";

$|=1;

system("rm /tmp/shellout.txt; touch /tmp/shellout.txt");
open(A,"|sh > /tmp/shellout.txt");

for $i (0..5) {
  print A "bc\n5+6\n";
  sleep 1;
}

die "TESTING";

open(B,"tail -f /tmp/shellout.txt|");

my($input,$output);

for (;;) {

  $input = <STDIN>;
  debug("STDIN READ: $input");
  print A $input;

  while (<B>) {
    debug("B READ: $_");
    if (/^\s*$/) {last;}
    print "GOT: $_\n";
  }

  sleep(1);
}

