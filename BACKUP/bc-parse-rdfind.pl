#!/bin/perl

# this is a oneoff program

# I tried to run rdfind as below:
# sudo rdfind -dryrun true -removeidentinode false -makesymlinks true dir1 dir2
# to free up disk space, but ran into issues. This program addresses
# those issues, which are given in comments

require "/usr/local/lib/bclib.pl";

# to be safe, I check the file existence and file size before
# deleting/symlinking anything; this is tedious, but I can reduce the
# number of files I consider by only looking at large files; how do I
# know a file is large without "-s"'ing it? I don't, but results.txt
# gives filesize at the time it ran, so I can use it to get a list of
# candidates that are large enough; of course, I will doublecheck
# later to make sure these files still exist and have proper size

open(A,"results.txt")||die("Can't open results.txt, $!");

while (<A>) {

  # by limiting the split here, I preserve spaces in the filename
  my($duptype, $id, $depth, $size, $device, $inode, $priority, $name) =
    split(/ /, $_, 9);

  # TODO: we could record more about the file here
  # TODO: we could limit size here instead of later
  # TODO: we could do file safety checks here instead of later
  $size{$name} = $size;
#  debug("NAME: $name");

}




die "TESTING";

# for permissions purposes (ugly!)
if ($>) {die("Must be root");}

my($bytes);

while (<>) {

  # TODO: ? I could've done this w/ arrays, but ... ?
  # make sure its a symlink recommendation
  # " to " HAS to be one space because some of my filenames end in spaces
  # <h>How bad is your life going if you filenames ending in spaces?</h>
  unless (/symlink\s*(.*?) to (.*)$/) {next;}

  my($f1, $f2) = ($1, $2);

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

  $bytes+= (-s $f2);
  if (rand()<.001) {debug("BYTES SAVED: $bytes");}

  # I am deleting the second file and linking to first, which is the
  # opposite of what rdfind normally does (I ran it backwards by
  # mistake + it would take forever to run again)
  print qq%rm "$f2"; ln -s "$f1" "$f2"\n%;

  #  debug("GOT: $f1 -> $f2, $n1 -> $n2, $m1 -> $m2");
}
