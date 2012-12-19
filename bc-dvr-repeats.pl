#!/bin/perl

# Another program thats useful only to me, and, even then, just
# barely.  Looks at list of DVR recordings (dvr-list.txt), determines
# which ones are exact duplicates (except for date/time), prints all
# lines, but especially marks those that are duplicates

# DVR list line format (example):
# 1500 jul 29 FF: Metel/Anthony/Harvey WATCHED
# time date show_abbreviation show_unique_key extra_information

# Tried doing this via shell and got as far as
# perl -anle 's/([a-z]{3})(\d{2})/$1 $2/i; print $_' dvr-list.txt | egrep -iv '25k|100k' | sort -f -k4 -k2M -k3n -k1n | uniq -f 3 -i --all-repeated | perl -anle '$str=lc(join(",",@F[3..$#F])); if ($seen{$str}) {print "$_ REPEATS $whole{$str}"} else {$seen{$str}=1; $whole{$str}=$_; print "DND: $_"}' | sort -f -k2M -k3n -k1n
# before giving up

# This program is idempotent; running it again on its own results
# shouldnt change it

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/, read_file("/home/barrycarter/dvr-list.txt"))) {

  # cheating somewhat below, since I know file is in date order (wasnt
  # originally, but is now)

  # make a copy of the line for parsing
  $i2 = $i;

  # format "1500 jul 29 ..." allowing for "jul 29" and "1500???"
  # I fastidiously use two digit dates
  unless ($i2=~s/^\d{4}\?* (jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec) ?\d{2} //i) {
    # not a show line, print as is
    print "$i\n";
    next;
  }

  # is a show line... have we seen it already?
  if ($seen{$i2}) {
    print "DELETEME: $i REPEATS $seen{$i2}\n";
    next;
  }

  # havent seen it already, so record and print
  $seen{$i2} = $i;
  print "$i\n";

}





