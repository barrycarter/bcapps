#!/bin/perl

# Given a list of books (files) in sorted size order, print out things
# that are books and do not appear to be repeats of other books

# NOTE: this is currently extremely ill-defined

require "/usr/local/lib/bclib.pl";

my($count,$tot);

while (<>) {
  chomp;
  my(@arr) = split(/\s+/,$_,9);
  my($fname, $size, $type) = @arr[-1,1,4];
  unless ($type eq "f") {next;}

  # get extension
  my($ext);
  if ($fname=~/^.*\.(.*)$/) {$ext=$1;} else {$ext="";}

  # Aldiko accepts only epub (is that really true?)
  unless (lc($ext) eq "epub") {next;}

  $tot+=$size;

  if ($tot>4e+9) {last;}

  # use generic name to avoid confusing android
  $count++;

  print qq%cp "$fname" /Volumes/POLARIS/BOOKS/book$count.epub\n%;
}
