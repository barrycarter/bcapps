#!/bin/perl

# Problem: I want to rsync drive1 to drive2, but many files on drive1
# are already on drive2, they just happen to be in the wrong
# subdirectories

# This program suggests mv commands (but no overwrites just to be
# safe) on drive2 that will make it look more like drive1

# files are considered "identical" if they have the same filename (not
# path) and size

# Usage: $0 file1 file2
# where file1 and file2 are greps from what bc-unix-dump.pl produces

# not sure this is useful to anyone, not even necessarily me?

require "/usr/local/lib/bclib.pl";

mkdir("/tmp/bcmovefiles");
chdir("/tmp/bcmovefiles");

# we're going to join on the filename (w/o dir part) and size, but
# need the full name for the mv command

my(@f) = @ARGV;

open(A,$f[0]);

while (<A>) {
  chomp;
  my($mtime,$size,$inode,$perm,$type,$gname,$uname,$devno,$name) = 
    split(/\s+/, $_, 9);

  # TODO: maybe add a size filter... only care about biggish files

  # if I decide to use mtime, snip off decimals
  $mtime=~s/\..*$//;

  # ignore directories, sockets, pipes, character/block devices + symlinks
  if ($type=~/^[dspcbl]$/) {next;}

  # split into dir and pure filename
  $name=~s%^(.*)/(.*?)$%%;
  my($dir,$file) = ($1,$2);

  # joining (using mtime for now, but may drop)
  # the dir is not part of the join condition
  print "$mtime $size $file\0$dir\n";

}
