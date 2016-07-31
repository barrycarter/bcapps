#!/bin/perl

# attempt to put ISD hourly temperature data into MySQL, but worried
# that, even though MySQL should handle big data, my machine may not

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  debug("PROCESSING: $i");
  open(A,"zcat $i|");

  while (<A>) {
    chomp;
    debug("$i $_");
    debug("GOT: $_");
  }
}
