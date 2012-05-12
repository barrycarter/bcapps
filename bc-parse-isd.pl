#!/bin/perl

# For each weather station in isd-lite, output for each hour of year:
# number of observations, average, coefficient of linear regression,
# constant of linear regression

# To obtain all isd-lite data (it's a LOT!):
# ncftpget -T -R ftp://ftp3.ncdc.noaa.gov/pub/data/noaa/isd-lite/

# Stations identified as "USAF-WBAN"; see db/ish-history.csv for more info
# Example: 723650-23050 is KABQ, 723647-03034 and 723647-99999 are KAEG.
# This program assumes (incorrectly) that each USAF-WBAN pair
# represents a uniq weather station.

# First ran this program in the directory with isd-lite data 
# (using find on individual stations is too slow):
# find . -type f > allfiles.txt

# To get list of all stations to run this in parallel in random order:

# perl -nle 'if (m%/(\d+\-\d+)\-\d{4}\.gz$%) {print "bc-parse-isd.pl
# $1";}' allfiles.txt | sort -R | uniq > allcmds.txt

push(@INC,"/usr/local/lib");
require "bclib.pl";

unless (-f "allfiles.txt") {die "Wrong directory, or run 'find . -type f > allfiles.txt";}

(($stat) = @ARGV) || die("Usage: $0 <station>");

# $stat.res.bz2 is the resulting file
# compressing due to large size, would fill up disk otherwise(?)
if (-f "$stat.res.bz2") {
  warn "$stat.res.bz2 exists";
  exit(0);
}

# combine all data for this station into one file
# (which we must delete later due to space considerations)

unless (-f "$stat.all") {
  system("egrep '$stat-....\.gz' allfiles.txt | xargs zcat > $stat.all");
}

# I plan to run this using "parallel", so keep memory profile low and
# not using read_file()

open(A,"$stat.all");

while (<A>) {
  # per isd-lite-format.txt (not all of these fields are used)
  ($yr, $mo, $da, $hr, $temp, $dewp, $slp, $wdir, $wspd, $cover) = 
    split(/\s+/, $_);

  # store year/temp pair
  # TODO: do this better?
  unless ($temp == -9999) {
      push(@{$temp{$mo}{$da}{$hr}}, "$yr:$temp");
    }

}

close(A);

open(B, ">$stat.res");

for $mo (sort keys %temp) {
  for $da (sort keys %{$temp{$mo}}) {
    for $hr (sort keys %{$temp{$mo}{$da}}) {
      @l = @{$temp{$mo}{$da}{$hr}};
      warn("TEMPS FOR $mo/$da/$hr:". join(",",@l));
      # calculate average (TODO: better way, sans subroutine?)
      # note how many obs for average (could be relevant)
#      $sum = 0;
#      $size = $#l+1;
#      for $i (@l) {$sum+=$i;}
      # final 10. is because data is given as temp*10
#      $avg = $sum/$size/10.;
#      print B "$mo $da $hr $avg $size\n";
    }
  }
}

close(B);

# turns out *.all files fill up disk, so...
system("rm -f $stat.all; bzip2 $stat.res");
