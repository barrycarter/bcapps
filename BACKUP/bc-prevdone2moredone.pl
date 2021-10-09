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
  my($null, $file, $time) = split(/\0/, $_);

  $origfile = $file;

  # always print out the original, gz, bz2

  # because .gz and .bz2 extensions must occur "at same time" can't
  # softcode them, must hardcode

  local_printfile($file, $time);

  # loop through regex

  for $j (@pubregex) {

    if ($file=~s/$j->[0]/$j->[1]/) {
      debug("$j->[0] -> $j->[1]");
      local_printfile($file, $time); 
    }
  }

  $file = $origfile;

  debug("NOW PRIV");

  for $j (@privregex) {

    if ($file=~s/$j->[0]/$j->[1]/) {
      debug("$j->[0] -> $j->[1]"); 
      local_printfile($file, $time); 
    }
  }
}

# TODO: use egrep to do this efficiently perhaps (but try going through all first?)

# given a file and a time, print out file with time and also file.gz
# and file.bz2 and if file ends in tbz/tgz/tar, all three of those as
# well (putting here to avoid redundant code)

sub local_printfile {

  my($file, $time) = @_;

  # the compressed versions

  # for some reason I have 140K+ files that are .gz.bz2

  print "\0$file\0$time\n";
  print "\0$file.gz\0$time\n";
  print "\0$file.bz2\0$time\n";
  print "\0$file.gz.bz2\0$time\n";

  # the tar bizarreness

  if ($file=~s/\.(tar|tgz|tbz)$//) {
      print "\0$file.tar\0$time\n";
      print "\0$file.tgz\0$time\n";
      print "\0$file.tbz\0$time\n";
    }
}
