#!/bin/perl

# Finds the average hourly temperature (and other potentially useful
# averages) for a given station over multiple years, provided that
# current directory contains the results of the following command
# (returns about 16G+ compressed data, 500K+ files):
#
# ncftpget -T -R ftp://ftp3.ncdc.noaa.gov/pub/data/noaa/isd-lite/

# Stations identified as "USAF-WBAN"; see db/ish-history.csv for more info
# Example: 723650-23050 is KABQ, 723647-03034 and 723647-99999 are KAEG

# First ran this program (using find on individual stations is too slow):
# find . -type f > allfiles.txt

# For this program, each USAF-WBAN number is treated as a different station

unless (-f "allfiles.txt") {die "Wrong directory, or run 'find . -type f > allfiles.txt";}

# using KABQ as test
$stat = "723650-23050";

# The sort below is unnecessary; only storing uncompressed data for
# "fun", could just use and discard

unless (-f "$stat.all") {
  system("egrep '$stat-....\.gz' allfiles.txt | xargs zcat | sort -n > $stat.all");
}

# I plan to run this using "parallel", so keep memory profile low and
# not using read_file()

open(A,"$stat.all");

while (<A>) {
  # per isd-lite-format.txt (not all of these fields are used)
  ($yr, $mo, $da, $hr, $temp, $dewp, $slp, $wdir, $wspd, $cover) = 
    split(/\s+/, $_);

  # just temp for right now, store all values for $mo/$da/$hr
  unless ($temp == -9999) {
      push(@{$temp{$mo}{$da}{$hr}}, $temp);
    }

}

close(A);

for $mo (sort keys %temp) {
  for $da (sort keys %{$temp{$mo}}) {
    for $hr (sort keys %{$temp{$mo}{$da}}) {
      print "$mo/$da/$hr -> \n";
      print join(", ", @{$temp{$mo}{$da}{$hr}}),"\n";
    }
  }
}

