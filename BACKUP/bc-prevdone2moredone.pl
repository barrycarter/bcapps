#!/bin/perl

# given a list of files that have already been backed up, pretend
# those files have also been backed up in other locations (eg, if a
# file is moved from one directory to another)

require "/usr/local/lib/bclib.pl";

# read a list of regex substitutions in the format '"X" "Y"' where
# regex Y is changed to string X (not sure why I thought I needed
# hashes here); X is the current location of the file and Y is the old
# location of the file (where it was when it was backed up)


my(@converts) = `egrep -hv '^ *\$|^#' $bclib{githome}/BACKUP/bc-conversions.txt $bclib{home}/BCPRIV/bc-conversions-private.txt`;

my(@regex);

for $i (@converts) {
    unless ($i=~/^\"(.*?)\" \"(.*?)\"$/) {die "BAD LINE: $_";}

    # push the from to (in that order to list of @regex

    push(@regex, [$2, $1]);
  }

debug(@regex);

# now read previouslydone.txt.srt and create version with fake backup locations (in other words, backup locations for where the files are now)

open(A,"previouslydone.txt.srt")||die("Can't open previouslydone.txt.srt, $!");

while (<A>) {

  chomp();
  my($file, $time) = split(/\0/, $_);

  # always print out the original, gz, bz2

  print "$file\0$time\n";
  print "$file.gz\0$time\n";
  print "$file.bz2\0$time\n";

  # loop through regex

  for $j (@regex) {
    
    # dont change $file directly
    my($x) = $file;

    if ($x=~s/$j->[0]/$j->[1]/) {
      debug("NEW: $file -> $x");
      print "$x\0$time\n";
    }
  }
}

# TODO: use egrep to do this efficiently perhaps (but try going through all first?)

