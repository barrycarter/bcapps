#!/bin/perl

# converts numbers ie IEEE-754 format to "real" numbers

# See http://stackoverflow.com/questions/21511224/how-to-read-daf-double-precision-array-file-transfer-files

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;
  if (/^\'(\-)?([A-F0-9]+)\^(\d+)\'$/) {
    debug("NUM: $1/$2/$3");
  }

}

