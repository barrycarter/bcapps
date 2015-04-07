#!/bin/perl

# Input is left join of all files on all drives (afad.txt) and all
# files I've already backed up in format:
# mtime filename-without-extension\0extension\0size
# where \0 = separator and "mtime filename-without-extension" is the join key

# normally invoked as "tac leftjoin.txt | $0"

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;
  my(@data) = split(/\0/,$_);

  # 2 fields = must backup, 3 fields = already backed up, else = bad
  my($nfields) = scalar(@data);

  if ($nfields==2) {
    print "$data[1] $data[0]\n";
  } elsif ($nfields==3) {
    # do nothing
  } else {
    warn("BAD FIELDS: $_");
  }
}

