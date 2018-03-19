#!/bin/perl

# converts files into "tar tv --utc" format into backup-compatible
# exclusion filse with lines like:
# file\0mtime

require "/usr/local/lib/bclib.pl";

# read list of conversions
open(A,"egrep -hv '^ *\$|^#' $bclib{githome}/BACKUP/bc-conversions.txt $bclib{home}/bc-conversions-private.txt|");

my(%convert);

while (<A>) {
  chomp;
  unless (/^\"(.*?)\" \"(.*?)\"$/) {die "BAD LINE: $_";}
  $convert{$1} = $2;

}

# we're going to use convert a lot, no need to compute keys repeatedly
my(@keys) = keys %convert;

while (<>) {
  chomp;

  my($perms, $owner, $size, $date, $time, $name) = split(/\s+/,$_,6);

  $name = "/$name";

  for $i (@keys) {$name=~s/$i/$convert{$i}/;}

  $mtime = str2time("$date $time UTC");
  print "$name\0$mtime\n";
}
