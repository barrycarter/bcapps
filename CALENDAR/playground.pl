#!/bin/perl

require "/usr/local/lib/bclib.pl";

# parsing semi-odd CSV format per emiliem.ch@gmail.com

my($all) = read_file("impdates-more.csv");

for $i (split(/\r/,$all)) {
  my(@l) = split(/\;/,$i);
  debug("NEW EVENT");
  debug("NUM: $#l");
  for $j (@l) {
    debug("ELT: $j");
  }
}
