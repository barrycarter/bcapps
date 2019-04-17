#!/bin/perl

# converts the SRTM data to binary

# to use zcat N00W030.zip | $0

require "/usr/local/lib/bclib.pl";

while (<>) {

  unless (/^\s*[\-\d]/) {
    warn "BAD LINE: $_";
    next;
  }

  my(@vals) = split(/\s+/, $_);

  for $i (@vals) {
    my($val) = $i==-9999?0:$i + 32767;
    my($b1) = floor($val/256);
    my($b2) = $val%256;
    print chr($b1),chr($b2);
  }

}
