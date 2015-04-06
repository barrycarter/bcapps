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
  if (scalar(@data)==3) {print "$_\n"; next;}

  # only remaining case should be 5 fields
  unless (scalar(@data)==5) {warn "BAD FIELDS: $_";}

  my($join,$ext1,$size1,$ext2,$size2) = @data;

  # if perfect match, already backed up
  if ($ext1 eq $ext2 && $size1 eq $size2) {next;}

  # backed up with stripped extension
  if ($badext{$ext1} && $ext2 eq "") {next;}

  # no extension match, so, yes, bakcup
  debug("GO: $_");

  # corner cases now, look at extensions



  if ($ext1 eq "bz2") {
    debug("SPECIAL: $_");
  }

  # otherwise, may need to back this up (but special cases apply)
#  debug("THUNK: $_");
}


