#!/bin/perl

# given a list of files that have already been backed up, pretend
# those files have also been backed up in other locations (eg, if a
# file is moved from one directory to another)

require "/usr/local/lib/bclib.pl";

# read a list of regex substitutions in the format '"X" "Y"' where
# regex Y is changed to string X (not sure why I thought I needed
# hashes here); X is the current location of the file and Y is the old
# location of the file (where it was when it was backed up)

# have to treat the private and public lists separately

my(@pubconvert) = `egrep -v '^ *\$|^#' $bclib{githome}/BACKUP/bc-conversions.txt`;
my(@privconvert) = `egrep -v '^ *\$|^#' $bclib{home}/BCPRIV/bc-conversions-private.txt`;

my(@pubregex, @privregex);

for $i (@pubconvert) {
  unless ($i=~/^\"(.*?)\" \"(.*?)\"$/) {die "BAD LINE: $_";}
  
  # push the from to (in that order to list of @regex
  
  push(@pubregex, [$2, $1]);
}

for $i (@privconvert) {
  unless ($i=~/^\"(.*?)\" \"(.*?)\"$/) {die "BAD LINE: $_";}
  
  # push the from to (in that order to list of @regex
  
  push(@privregex, [$2, $1]);
}

# now read previouslydone.txt.srt and create version with fake backup locations (in other words, backup locations for where the files are now)

# open(A,"previouslydone.txt.srt")||die("Can't open previouslydone.txt.srt, $!");

# rewritten to take stdin and print stdout, so much easier for testing

while (<>) {

  chomp();
  my($file, $time) = split(/\0/, $_);

  # always print out the original, gz, bz2

  print "$file\0$time\n";

  # store the original filename since we have to run it through two lists
  my($origfile) = $file;

  # loop through regex

  for $j (@pubregex) {
    # we now run the files through EACH regex, one at a time (order matters)
    if ($file=~s/$j->[0]/$j->[1]/) {
      debug("$j->[0] -> $j->[1]");
      print "$file\0$time\n";
    }
  }

  $file = $origfile;

  debug("NOW PRIV");

  for $j (@privregex) {
    # we now run the files through EACH regex, one at a time (order matters)
    if ($file=~s/$j->[0]/$j->[1]/) {
      debug("$j->[0] -> $j->[1]");
      print "$file\0$time\n";
    }
  }
}

# TODO: use egrep to do this efficiently perhaps (but try going through all first?)

