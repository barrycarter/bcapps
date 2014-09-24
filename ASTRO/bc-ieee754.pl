#!/bin/perl

# Given a list of files containing quoted IEEE754 numbers (as in the
# "toxfr" version of .bsp SPICE files, namely .xsp SPICE files),
# creates a new file with decimal versions of those numbers. All
# non-quoted numbers are copied as is. Options:

# --clobber: overwrite output file if it exists

# NOTE: .xsp files sometimes contain *unquoted* numbers (often the
# number 1024) for legacy reasons; these numbers are copied as is,
# since they are not quoted.

# See also:
# http://stackoverflow.com/questions/21511224/how-to-read-daf-double-precision-array-file-transfer-files

# TODO: Makefile (toxfr, this proggie)

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  unless ($i=~/\.xsp$/) {
    warn "Filename does not end in .xsp, ignoring";
    next;
  }

  if (-f "$i.dec" && !$globopts{clobber}) {
    warn "Output file $i.dec exists, ignoring";
    next;
  }

  open(A,$i);
  open(B,">$i.dec");
  open(C,">$i.dec.m");

  while (<A>) {
    print B ieee754todec($_),"\n";
    print C ieee754todec($_,"mathematica=1"),"\n";
  }
  close(A);
  close(B);
}
