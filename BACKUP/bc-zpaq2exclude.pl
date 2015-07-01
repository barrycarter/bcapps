#!/bin/perl

# Given the output of "zpaq list", outputs data that can be used to
# exclude these files from next backup (via mtime and filename)

# --special: if set to 1, print out "mtime.0000000000 size\0name" for
# obscure one off case

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;
  my($symb, $date, $dtime, $size, $mode, $file) = split(/\s+/,$_,6);

  # ignore directories
  if ($mode=~/^d/) {next;}

  unless ($symb eq "-") {warn("SKIPPING: $_"); next;}

  # strip directory head (where I rsync stuff)
  unless ($file=~s%^ROOT/%/% || $globopts{special}){warn "BAD FILENAME: $file";}

  # want to sort by time descending, see bc-format2altformat.pl for details
  my($time) = 2**33-str2time("$date $dtime UTC");

  # special case
  if ($globopts{special}) {
    # NOTE: yes, this hides the definition above
    my($time) = str2time("$date $dtime UTC").".0000000000";
    print "$time $size\0$file\n";
    next;
  }

  # in addition to the file I actually backed up, claim to have backed
  # up the bz2 and gz versions of the file
  # including $size here is semi-pointless?
  print "$time $file\0$size\n";
  print "$time $file.bz2\0$size\n";
  print "$time $file.gz\0$size\n";

  # if $file ends in .tar, claim to have backed up the tgz/tbz versions as well
  if ($file=~s/\.tar$//) {
    print "$time $file.tbz\0$size\n";
    print "$time $file.tgz\0$size\n";
  }
}

