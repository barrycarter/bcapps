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

  # if the size and extension match, we definitely have backed this up already
  if ($ext1 eq $ext2 && $size1 == $size2) {next;}

  # if the 


  if ($ext1 eq "bz2") {
    debug("SPECIAL: $_");
  }

  # otherwise, may need to back this up (but special cases apply)
#  debug("THUNK: $_");
}


