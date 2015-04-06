#!/bin/perl

# Input is left join of all files on all drives (afad.txt) and all
# files I've already backed up in format:
# mtime filename-without-extension\0extension\0size
# where \0 = separator and "mtime filename-without-extension" is the join key

# normally invoked as "tac leftjoin.txt | $0"

require "/usr/local/lib/bclib.pl";

# extensions that bc-chunk-backup.pl strips
my(%badext) = list2hash("bz2","tbz","tgz","gz");

while (<>) {
  chomp;

  my(@data) = split(/\0/,$_);

  # if only 3 fields, no join match, so definitely backup
  if (scalar(@data)==3) {doprint($_); next;}

  # only remaining case should be 5 fields
  unless (scalar(@data)==5) {warn "BAD FIELDS: $_";}


  debug("POSSIBLE MATCH: $_");
  my($join,$ext1,$size1,$ext2,$size2) = @data;

  # if perfect match, already backed up
  if ($ext1 eq $ext2 && $size1 eq $size2) {next;}

  # backed up with stripped extension
  if ($badext{$ext1} && $ext2 eq "") {next;}

  # no extension match, so, yes, bakcup
  doprint($_);
}

# prints the line in proper format for bc-chunk-backup.pl, restoring
# extension and reordering fields

sub doprint {
  my($str) = @_;

  # TODO: redundant coding, yuck
  my($join,$ext1,$size1,$ext2,$size2) = split(/\0/,$_);

  if ($ext1) {$join="$join.$ext1";}
  print "$size1 $join\n";
}


