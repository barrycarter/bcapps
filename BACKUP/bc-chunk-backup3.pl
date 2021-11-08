#!/bin/perl

# version 3 uses the format for afad-minus-egrep-fgrep-previous-backup.txt

# --checkfile: check that each file actually exists (slow)
# --limit=25,000,000,000: limit to this many bytes total

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# rewriting 27 Feb 2015 for a single file
# see README for file format

defaults("limit=10,000,000,000&xmessage=1");
$limit = $globopts{limit};

# lets me use commas
$limit =~s/,//g;

my($tot, $count, $null, $name, $mtime, $size);

open(A,">filelist.txt");
open(B,">statlist.txt");
open(C,">doesnotexist.txt");

while (<>) {
  chomp;

  my($orig) = $_;
  if (++$count%10000==0) {debug("COUNT: $count, BYTES: $tot, MTIME: $mtime");}
  if ($tot>=$limit) {last;}

  ($null, $name, $mtime, $size) = split(/\0/, $_);

  # this slows things down a lot, but it useful when I've been making
  # changes to the fs
  if ($globopts{checkfile} && !(-f $name)) {
    print C "$name\n";
    warn("NOSUCHFILE: $name");
    next;
  }

  $tot+= $size;

  # TODO: if $size is small (indicating symlink or pointlessness,
  # don't add to this list) [256 = max length of filename and thus of
  # symlink?]

  # to keep mtime as one field (later implicit in bc-unix-dump.pl)
#  $mtime=~s/\s+/T/g;

  # NOTE: to avoid problems w/ filesizes > $limit, we add to chunk
  # first and THEN check for overage
  print A "$name\n";
  print B "$size $mtime $name\n";
}

debug("Used $count files to meet total, earliest ts: $mtime");

# below is just to avoid "egrep: writing output: Broken pipe" errors
# TODO: is this the best way to handle those errors
# $count = 0;
# while (<>) {if (++$count%100000==0) {debug("IGNORE COUNT: $count");}}

close(A); close(B); close(C);

# TODO: restore this
# do this so we're not waiting on egrep

open(A,"|parallel -j 2");
print A "bc-total-bytes.pl statlist.txt | sort -nr >| big-by-dir.txt\n";
print A "sort -k1nr statlist.txt >| big-by-file.txt\n";
close(A);
