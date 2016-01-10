#!/bin/perl

# Converts a list of filenames to standardized names with timestamp
# and original name

# --zpaqlist: input list is in zpaq TOC format

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

  my($mtime,$size,$inode,$perm,$type,$gname,$uname,$devno,$name,$symb,$date,$dtime);

  # if --zpaqlist mode, convert zpaq list to similar format
  if ($globopts{zpaqlist}) {

    ($symb, $date, $dtime, $size, $type, $name) = split(/\s+/,$_,6);
    unless ($symb eq "-") {warn("SKIPPING: $_"); next;}
    # strip name of ROOT/
    unless ($name=~s%^ROOT/%/%) {warn "BAD FILENAME: $name";}
    # fix mtime
    $mtime = str2time("$date $dtime UTC");
    # type is really type + permmode, so fix
    $type=~s/\d//g;
    if ($type eq "") {$type="f";}

  } else {

    ($mtime,$size,$inode,$perm,$type,$gname,$uname,$devno,$name) = 
      split(/\s+/, $_, 9);
  }

  my($origname) = $name;

  # recognized types I want to ignore
  if ($type=~/^[dspcbl]$/) {next;}

  # ignore other nonfiles, but warn
  unless ($type=~/^[f]$/) {warn "BAD TYPE: $_"; next;}

  # zpaq rounds mtime down to nearest second
  $mtime=~s/\..*$//;

  # canonize/standardize/normalize name
  for $i (@keys) {$name=~s/$i/$convert{$i}/;}

  # spit out mtime and standardized name (our "key"), origname ("value"),
  # and size (because we'll need it later)

  # for zpaqlist, just need mtime and standardized name

  if ($globopts{zpaqlist}) {
    print "$mtime $name\n";
  } else {
    print "$mtime $name\0$origname\0$size\n";
  }
}
