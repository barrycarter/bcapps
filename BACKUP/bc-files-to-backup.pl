#!/bin/perl

# Input is left join of all files on all drives (afad.txt) and all
# files I've already backed up in format:
# mtime filename-without-extension\0extension\0size
# where \0 = separator and "mtime filename-without-extension" is the join key

# normally invoked as "tac leftjoin.txt | $0"

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;

  my($mtimename,$ext1,$size1,$ext2,$size2) = split(/\0/,$_);

  # this is actually the reverse of what we want, just testing for now
  if (length($size2)>0) {
    # only show special cases (where extension/size nonidentical)
    if (($ext1 ne $ext2) || ($size1 != $size2)) {
      debug("THUNK: $_");
    }
  }
}


