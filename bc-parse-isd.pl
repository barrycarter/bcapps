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

# To get list of all stations to run this in parallel in random order:

# perl -nle 'if (m%/(\d+\-\d+)\-\d{4}\.gz$%) {print "bc-parse-isd.pl
# $1";}' allfiles.txt | sort -R | uniq > allcmds.txt

# This program runs on a "special" machine, where bclib.pl may not be
# available

# For this program, each USAF-WBAN number is treated as a different station

unless (-f "allfiles.txt") {die "Wrong directory, or run 'find . -type f > allfiles.txt";}

(($stat) = @ARGV) || die("Usage: $0 <station>");

# The sort below is unnecessary as is the ">"; only storing
# uncompressed data for "fun", could just use and discard

unless (-f "$stat.all") {
  system("egrep '$stat-....\.gz' allfiles.txt | xargs zcat > $stat.all");
}

# $stat.res is the resulting file
if (-f "$stat.res") {
#  print "All finished, sir\n";
  exit(0);
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

open(B, ">$stat.res");

for $mo (sort keys %temp) {
  for $da (sort keys %{$temp{$mo}}) {
    for $hr (sort keys %{$temp{$mo}{$da}}) {
      @l = @{$temp{$mo}{$da}{$hr}};
      # calculate average (TODO: better way, sans subroutine?)
      # note how many obs for average (could be relevant)
      $sum = 0;
      $size = $#l+1;
      for $i (@l) {$sum+=$i;}
      # final 10. is because data is given as temp*10
      $avg = $sum/$size/10.;
      print B "$mo $da $hr $avg $size\n";
    }
  }
}

close(B);

# turns out *.all files fill up disk, so...
system("rm -f $stat.all; bzip2 $stat.res");
