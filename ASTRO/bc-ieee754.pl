#!/bin/perl

# converts numbers ie IEEE-754 format to "real" numbers

# See http://stackoverflow.com/questions/21511224/how-to-read-daf-double-precision-array-file-transfer-files

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;
  if (/^\'(\-)?([A-F0-9]+)\^(\d+)\'$/) {
    my($sign, $mant, $exp) = ($1,$2,$3);
    debug("HEX:",hex($mant)/(16**length($mant))*(16**$exp));
    debug("$sign/$mant/$exp");
  }
}
