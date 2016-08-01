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

# perl -nle 'if (m%/(\d+\-\d+)\-\d{4}\.gz$%) {print "bc-parse-isd.pl
# $1";}' allfiles.txt | sort -R | uniq > allcmds.txt

# run using parallel:
# (parallel -j 32 --joblog parjoblog.txt < allcmds.txt) >&! parouterr.txt &

require "/usr/local/lib/bclib.pl";

unless (-f "allfiles.txt") {die "Wrong directory, or run 'find . -type f > allfiles.txt";}

(($stat) = @ARGV) || die("Usage: $0 <station>");

# $stat.res.bz2 is the resulting file (if empty, something is wrong)
# compressing due to large size, would fill up disk otherwise(?)
if (-s "AVGSD/$stat.res.bz2") {
  warn "AVGSD/$stat.res.bz2 exists";
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
      push(@{$temp{$mo}{$da}{$hr}}, $temp);
    }

}

close(A);

open(B, ">AVGSD/$stat.res");

for $mo (sort keys %temp) {
  for $da (sort keys %{$temp{$mo}}) {
    for $hr (sort keys %{$temp{$mo}{$da}}) {
      @l = @{$temp{$mo}{$da}{$hr}};

      debug("L IS",join(" ",@l));
      my(%hash) = %{list2avgsd(\@l)};

      debug("HASH IS",join(" ",%hash));

      next; # TODO: TESTING!

      # do linear regression, etc
      @x = ();
      @y = ();
      for $i (@l) {
	($yr,$val) = split(/\:/, $i);
	# treating 2000 as 0
	push(@x,$yr-2000);
	# value is actually temp*10 (celsius)
	push(@y,$val);
      }

     debug("X",@x,"Y",@y);
      debug("FOR $mo/$da/$hr:");
      ($b, $m, $avg) = linear_regression2(\@x,\@y);
      # number of reports
      $size = scalar(@x);

      # and output...
      print B "$stat $mo $da $hr $size $avg $m $b\n";
    }
  }
}

close(B);

# turns out *.all files fill up disk, so...
warn "NOT DELETEING/COMPRESSING DURING TESTING";

# system("rm -f $stat.all; bzip2 AVGSD/$stat.res");

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
  for $i (@l) {$sum+=($i-$hash{mean})**2; debug("SUM: $sum, I: $i, HM: $hash{mean}");}
  # n-1 below because of finite size (sample sd)
  $hash{sd} = sqrt($sum/($n-1));

  return \%hash;
}
