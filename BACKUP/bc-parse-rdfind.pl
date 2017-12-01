#!/bin/perl

# this is a oneoff program

# I tried to run rdfind as below:
# sudo rdfind -dryrun true -removeidentinode false -makesymlinks true dir1 dir2
# to free up disk space, but ran into issues. This program addresses
# those issues, which are given in comments

require "/usr/local/lib/bclib.pl";

# for permissions purposes (ugly!)
if ($>) {die("Must be root");}

# to be safe, I check the file existence and file size before
# deleting/symlinking anything; this is tedious, but I can reduce the
# number of files I consider by only looking at large files; how do I
# know a file is large without "-s"'ing it? I don't, but results.txt
# gives filesize at the time it ran, so I can use it to get a list of
# candidates that are large enough; of course, I will doublecheck
# later to make sure these files still exist and have proper size

# to make things even more efficient, results.txt.srt is generated as:
# sort -k4nr results.txt > results.txt.srt
# the program can thus abort when the file size gets too small

# files below this size are ignored
my($lower) = 1e+6;

open(A,"results.txt.srt")||die("Can't open results.txt, $!");

while (<A>) {

  chomp;

  # by limiting the split here, I preserve spaces in the filename
  my($duptype, $id, $depth, $size, $device, $inode, $priority, $name) =
    split(/ /, $_, 9);

#  debug("NAME: $name");

  # if we've hit a file less than $lower, we assume files are sorted
  # by size, so abort
  if ($size < $lower) {last;}

  # TODO: we could record more about the file here
  # TODO: we could limit size here instead of later
  # TODO: we could do file safety checks here instead of later

#  debug("ASSIGNING $name to size $size");

  $size{$name} = $size;
}

# debug(%size);

my($bytes);

while (<>) {

  chomp;

  # TODO: ? I could've done this w/ arrays, but ... ?
  # make sure its a symlink recommendation
  # " to " HAS to be one space because some of my filenames end in spaces
  # <h>How bad is your life going if you filenames ending in spaces?</h>
  unless (/symlink\s*(.*?) to (.*)$/) {next;}

  my($f1, $f2) = ($1, $2);

#  debug("FILES: $f1 and $f2, $size{$f1}, $size{$f2}");

  # if the file size is undefined, ignore quietly
  if ($size{$f1} == 0 || $size{$f2} == 0) {next;}

  # check that at least the theoretic sizes are equal and large enough
  if ($size{$f1} < $lower) {warn "TOO SMALL: $f1 -> $size{$f1}"; next;}
  unless ($size{$f1} == $size{$f2}) {warn "UNEQUAL SIZE: $_, $size{$f1} vs $size{$f2}"; next;}

  # no quotes, but spaces/apostrophes ok + other printables (since I quote)

  unless ($f1=~/[ -~]/) {warn "BAD FILENAME: $f1"; next;}
  unless ($f2=~/[ -~]/) {warn "BAD FILENAME: $f2"; next;}

  # no apostrophes, quotes, or other types of spaces
  if ($f1=~/\"/) {warn "BAD FILENAME: $f1"; next;}
  if ($f2=~/\"/) {warn "BAD FILENAME: $f2"; next;}

  # my restriction: the filename itself must match (because otherwise
  # you get all sorts of weird random links)
  
  my($n1, $n2) = ($f1, $f2);
  $n1=~s%^.*/%%;
  $n2=~s%^.*/%%;

  # if either n1 or n2 is empty, warn and move on
  if ($n1=~/^\s*$/ || $n2=~/^\s*$/) {
    # this actually ignores a file whose name is " ", but I'm ok w/ that
    warn "BAD LINE: $_";
    next;
  }

  # unless names are equal move on
  unless ($n1 eq $n2) {next;}


  # I'm only looking for cross-device repeats, so check mount points
  # my point points start with /mnt, yours may not
  # this also confirms I have full paths, which helps w symlinks
  unless ($f1=~m%^/mnt/(.*?)/%) {warn("NOTMNT: $f1"); next;}
  my($m1) = $1;
  unless ($f2=~m%^/mnt/(.*?)/%) {warn("NOTMNT: $f2"); next;}
  my($m2) = $1;

  if ($m1 eq $m2) {next;}

  # this check is VERY specific to me; I could've included it above,
  # but am separating it if others want to use this
  unless ($m1 eq "extdrive5" && $m2 eq "kemptown") {next;}

  # painful (slow) test saved for last: target must exist and not be
  # symlink itself

  unless (-f $f1) {warn("NO TARGET: $f1"); next;}
  if (-l $f1) {warn("TARGET IS SYMLINK: $f1"); next;}

  # ignore cases where source is already a symlink
  if (-l $f2) {warn("SOURCE IS SYMLINK: $f2"); next;}

  # confirm actual sizes are same
  unless (-s $f2 == -s $f1) {warn("DIFFERENT SIZES: $_"); next;}

  $bytes+= (-s $f2);
  if (rand()<.01) {debug("BYTES SAVED: $bytes");}

  # I am deleting the second file and linking to first, which is the
  # opposite of what rdfind normally does (I ran it backwards by
  # mistake + it would take forever to run again)

  # sudo here is seriously ugly, but perms
  print qq%sudo rm "$f2"; sudo ln -s "$f1" "$f2"\n%;

  #  debug("GOT: $f1 -> $f2, $n1 -> $n2, $m1 -> $m2");
}

debug("TOTAL BYTES SAVED: $bytes");
