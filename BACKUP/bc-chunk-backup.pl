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

while (<>) {
  chomp;
  my($orig) = $_;

  if (++$count%100000==0) {debug("COUNT: $count, BYTES: $tot");}

  if ($tot>=$limit) {last;}

  my(%file);

  # TODO: in theory, could grab current file size using "-s"
  ($file{mtime},$file{size},$file{name}) =  split(/\s+/, $_, 3);

  # running four tests here is probably insanely inefficient
  # silently ignore directories, device files, etc
#  if (-d $file{name} || -c $file{name} || -b $file{name} || -S $file{name}) {
#    next;
#  }

  # TODO: this might slow things down excessively, even with caching
#  unless (-f $file{name} || -l $file{name}) {
#    warn "NO SUCH FILE: $file{name}";
#    next;
#  }

  $tot+= $file{size};

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$file{name}\n";
  print B "$orig\n";
}

close(A); close(B);

# TODO: really unhappy about this, should be able to do this in program
# system ("sort statlist1.txt -o statlist1.txt");

debug("Used $count files to meet total");

# TODO: check zpaq errors
