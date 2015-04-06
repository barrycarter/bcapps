#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# rewriting 27 Feb 2015 for a single file
# see README for file format

# TODO: $limit should be an option
my($limit) = 25e+9;
my($tot, $count);

open(A,">filelist.txt");
open(B,">statlist.txt");

# record files to bunzip2/gunzip (and others?), but exclude symlinks
# and put ROOT/ in front
open(C,">bunzip2.txt");
open(D,">gunzip.txt");

while (<>) {
  chomp;
  my($orig) = $_;
  if (++$count%10000==0) {debug("COUNT: $count, BYTES: $tot");}
  if ($tot>=$limit) {last;}

  # TODO: in theory, could grab current file size using "-s" (but too slow?)
  # this isn't real mtime, actually 2**33-mtime
  my($size,$mtime,$name) =  split(/\s+/, $_, 3);
  $tot+= $size;

  # compressed? (newline for now, change to null for xargs -0 later)
  if ($name=~/\.bz2$/ || $name=~/\.tbz$/) {print C "ROOT/$name\n";}
  if ($name=~/\.gz$/ || $name=~/\.tgz$/) {print D "ROOT/$name\n";}

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$name\n";
  print B "$orig\n";
}

debug("Used $count files to meet total");
close(A); close(B); close(C); close(D);


