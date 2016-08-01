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
if (-s "$stat.res.bz2") {
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

# system("rm -f $stat.all; bzip2 $stat.res");

# TODO: add below to bclib.pl

sub linear_regression2 {
  my($xref, $yref) = @_;
  my($sumxy, $sumx, $sumy, $sumx2, $cov, $var, $a, $b, @running);
  my(@x) = @{$xref};
  my(@y) = @{$yref};
  my($n) = scalar(@x);


  # TODO: special cases no longer return correct values?

  # empty list = special case
  if ($n==0) {return NaN,NaN,NaN;}

  # 1-elt list = special case?
  # TODO: is this really a special case?
  if ($n==1) {return NaN,NaN,$y[0];}

  # from wikipedia
  for $i (0..$#x) {
    $sumxy += $x[$i]*$y[$i];
    $sumx += $x[$i];
    $sumy += $y[$i];
    $sumx2 += $x[$i]*$x[$i];

    # convenience variable
    my($count) = $i+1;

    # intentionally computing this each time for "running regression"
    $cov = $sumxy/$count - $sumx*$sumy/$count/$count;
    $var = $sumx2/$count - $sumx*$sumx/$count/$count;
    if ($var) {
      $b = $cov/$var;
      $a = ($sumy-$b*$sumx)/$count;
    } else {
      ($a,$b) = ($y[0],0);
    }

    push(@running,$a,$b);
 }

  return $a,$b,$sumy/$count,
}

