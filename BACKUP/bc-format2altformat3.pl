#!/bin/perl

# Converts a list of filenames to standardized names with timestamp
# and original name

# verison 3 writes multiple files, one for just filenames (for sorting and exclusion purposes), one with filenames and mtimes (for sorting) and sizes (for total computing)

# --zpaqlist: input list is in zpaq TOC format
# --format3: output two files

require "/usr/local/lib/bclib.pl";

# read list of conversions
open(A,"egrep -hv '^ *\$|^#' $bclib{githome}/BACKUP/bc-conversions.txt $bclib{home}/bc-conversions-private.txt|");

my(%convert);

while (<A>) {
  chomp;
  unless (/^\"(.*?)\" \"(.*?)\"$/) {die "BAD LINE: $_";}
  $convert{$1} = $2;

}

close(A);

# if needed, open the two files we output too

if ($globopts{format3}) {
  # TODO: maybe check to see if these files already exist
  open(A, ">filelist.txt");
  open(B, ">filelist-mtime-size.txt");
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
  # TODO: this is broken, because in .bz2, the . is treated as a wildcard

  for $i (@keys) {$name=~s/$i/$convert{$i}/;}

  # spit out mtime and standardized name (our "key"), origname ("value"),
  # and size (because we'll need it later)

  # for zpaqlist, just need mtime and standardized name

  if ($globopts{zpaqlist}) {
    print "$name\0$mtime\n";
  } elsif ($globopts{format3}) {
    print A "$origname\n";
    print B "$origname\0$mtime\0$size\n";
  } else {
    print "$name\0$mtime\0$origname\0$size\n";
  }
}

=item schema

Schema for afad and prevback tables:

CREATE TABLE afad (mtime INT, name TEXT, origname TEXT, size INT);
CREATE TABLE prevback (mtime INT, name TEXT, origname TEXT, size INT);

-- one day, this 255 will come back to bite me...

CREATE INDEX uniq1 ON afad(mtime,name(255),origname(255),size);
CREATE INDEX uniq2 ON prevback(mtime,name(255),origname(255),size);

=cut

