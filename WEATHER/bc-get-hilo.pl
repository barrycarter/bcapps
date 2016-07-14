#!/bin/perl

# Given the untar of the file ghcnd_all.tar.gz in
# ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/ (size ~2.9 GB), and the
# subsequent bzip2 compression of the dly files, this program computes
# the frequency of each temperature and stores it compactly; because
# there are many stations, time is of the esscence in the program

require "/usr/local/lib/bclib.pl";

my($dir) = "/home/barrycarter/WEATHER/ghcnd_all";
chdir($dir)||die("Can't chdir");

# TODO: doing this in two batches (one for max temps and one for min
# temps) might be inefficient

# TODO: early versions might be not efficient (even more so than above)

for $i (glob "*.bz2") {

  my(%hash) = ();

  open(A,"bzegrep 'TMAX|TMIN' $i|");

  while (<A>) {

    # figure out if its a max or min and kill off
    s/^.*(TMAX|TMIN)\s*//;
    my($key) = $1;

    # split remainder, only even numbered fields contain data
    my(@vals) = split(/\s+/, $_);

    # the parens below are just to make emacs happy
    for $j (0..($#vals/2)) {$hash{$key}{$vals[$j*2]}++}

  }

  for $j (keys %{$hash{TMIN}}) {debug("$i -> $j -> $hash{TMIN}{$j}");}
}
