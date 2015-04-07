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

  # if 3 fields, already backed up, 1 or 4+ is bad
  my($nfields) = scalar(@data);
  if ($nfields<2 || $nfields>3) {warn "BAD FIELDS: $_"; next;}
  # if only 2 fields, no join match, so definitely backup
  if ($nfields==2) {doprint($_);}
}

# prints the line in proper format for bc-chunk-backup.pl, restoring
# extension and reordering fields

sub doprint {
  my($str) = @_;

  # TODO: redundant coding, yuck
  my($join,$size1,$size2) = split(/\0/,$_);

  print "$size1 $join\n";
}


