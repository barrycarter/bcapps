#!/bin/perl

require "/usr/local/lib/bclib.pl";

use iCal::Parser;

my $parser=iCal::Parser->new();
my $hash=$parser->parse("playground.ics");

debug(var_dump("hash",$hash));

die "TESTING";

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
