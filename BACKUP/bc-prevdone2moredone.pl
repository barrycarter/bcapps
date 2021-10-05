#!/bin/perl

# given a list of files that have already been backed up, pretend
# those files have also been backed up in other locations (eg, if a
# file is moved from one directory to another)

require "/usr/local/lib/bclib.pl";

# read list of conversions in format: '"X" "Y"' where X (in quotes) is
# where the file was originally backed up and Y (in quotes) is where
# we pretend the file was also backedup; multiple Y's are allowed for
# one X

# in these files, order is "Y" "X", but we build hash from X to Y

my(@converts) = `egrep -hv '^ *\$|^#' $bclib{githome}/BACKUP/bc-conversions.txt $bclib{home}/bc-conversions-private.txt`;

for $i (@converts) {
    unless ($i=~/^\"(.*?)\" \"(.*?)\"$/) {die "BAD LINE: $_";}

    # this is intentionally backwords
    my($key, $val) = ($2, $1);

    # hard dollar signs to nuls
    $key=~s/\$/\0/;

    $pretend{$key}=$val;

  }

for $i (sort keys %pretend) {debug("$i -> $pretend{$i}");}

# now read previouslydone.txt.srt and create version with fake backup locations

open(A,"previouslydone.txt.srt")||die("Can't open previouslydone.txt.srt, $!");

while (<A>) {

  chomp();
  my($file, $time) = split(/\0/, $_);

  # always print out the original, gz, bz2

  print "$file\0$time\n";
  print "$file.gz\0$time\n";
  print "$file.bz2\0$time\n";

  # loop through %pretend

  for $j (keys %pretend) {

    # dont change $_ directly
    my($x) = $file;

    if ($x=~s/$j/$pretend{$j}/) {
      debug("NEW: $file -> $x");
      print "$x\0$time\n";
    }
  }
}

# TODO: use egrep to do this efficiently perhaps (but try going through all first?)

