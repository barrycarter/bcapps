#!/bin/perl

# For each weather station in isd-lite, output for each hour of year:
# number of observations, average, coefficient of linear regression,
# constant of linear regression

# To obtain all isd-lite data (it's a LOT!):
# ncftpget -T -R ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/

# Stations identified as "USAF-WBAN"; see db/ish-history.csv for more info
# Example: 723650-23050 is KABQ, 723647-03034 and 723647-99999 are KAEG.
# This program assumes (incorrectly) that each USAF-WBAN pair
# represents a uniq weather station.

# First ran this program in the directory with isd-lite data 
# (using find on individual stations is too slow):
# find . -type f > allfiles.txt

# To get list of all stations to run this in parallel in random order:

# perl -nle 'if (m%/(\d+\-\d+)\-\d{4}\.gz$%) {print "bc-parse-isd2.pl
# $1 > AVGSD/$1.out";}' allfiles.txt | sort -R | uniq > allcmds.txt

# run using parallel:
# (parallel -j 32 --joblog parjoblog.txt < allcmds.txt) >&! parouterr.txt &

require "/usr/local/lib/bclib.pl";

unless (-f "allfiles.txt") {die "Wrong directory, or run 'find . -type f > allfiles.txt";}

(($stat) = @ARGV) || die("Usage: $0 <station>");

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
      push(@{$temp{$mo}{$da}{$hr}}, $temp);
    }

}

close(A);

for $mo (sort keys %temp) {
  for $da (sort keys %{$temp{$mo}}) {
    for $hr (sort keys %{$temp{$mo}{$da}}) {
      @l = @{$temp{$mo}{$da}{$hr}};

      my(%hash) = %{list2avgsd(\@l)};
      # and output...
      print join("\t",
 ($stat, $mo, $da, $hr, $hash{size}, $hash{median}, $hash{mean}, $hash{sd})),
 "\n";
    }
  }
}

system("rm -f $stat.all");

# TODO: add this to bclib.pl maybe

# given a (reference to a) list of numbers, compute mean, median, std
# dev, return as hash (which lets me return more stuff later)

sub list2avgsd {
  my($lref) = @_;
  my(@l) = @$lref;
  my(%hash);

  @l = sort {$a <=> $b} @l;
  my($n) = scalar(@l);
  $hash{size} = $n;

  # mean
  my($sum) = 0;
  for $i (@l) {$sum+=$i;}
  $hash{mean} = $sum/$n;

  # median is either element or average of two elts
  if ($n%2 == 1) {
    # example 5 elts = indices: 0,1,2,3,4, choice is 2
    $hash{median} = $l[($n-1)/2];
  } else {
    # example 4 elts = indicies: 0,1,2,3 choice is 1.5
    $hash{median} = ($l[$n/2]+$l[$n/2-1])/2;
  }

  # sd
  $sum = 0;
  for $i (@l) {$sum+=($i-$hash{mean})**2;}
  # n-1 below because of finite size (sample sd)
  $hash{sd} = sqrt($sum/($n-1));

  return \%hash;
}

=item schema

-- this is the 5816 stations for which there is 8784 rows of data,
-- 51087744 row total

CREATE TABLE hourly_averages (
 station TEXT, month INT, day INT, hour INT, nobs INT, median DOUBLE,
 mean DOUBLE, sd DOUBLE
);

CREATE INDEX i_station ON hourly_averages(station(20));
CREATE INDEX i_month ON hourly_averages(month);
CREATE INDEX i_day ON hourly_averages(day);
CREATE INDEX i_hour ON hourly_averages(hour);
CREATE INDEX i_nobs ON hourly_averages(nobs);
CREATE INDEX i_median ON hourly_averages(median);
CREATE INDEX i_mean ON hourly_averages(mean);
CREATE INDEX i_sd ON hourly_averages(sd);

-- this is the catted file

LOAD DATA INFILE "/home/barrycarter/WEATHER/isd-lite/AVGSD/mysql.tsv"
 INTO TABLE hourly_averages;

-- TODO: maybe exclude stations with too few years

-- below is without creating indexes first
-- Timing: Query OK, 51087744 rows affected (2 min 19.11 sec)
-- Results: Records: 51087744  Deleted: 0  Skipped: 0  Warnings: 0

-- below is when indexes are created first
-- Timing: Query OK, 51087744 rows affected (28 min 44.29 sec)
-- Results: Records: 51087744  Deleted: 0  Skipped: 0  Warnings: 0

=cut
