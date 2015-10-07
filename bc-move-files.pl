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

chdir("/home/barrycarter/20151007/bcmovefiles");

# we're going to join on the filename (w/o dir part) and size, but
# need the full name for the mv command

my(@f) = @ARGV;

for $i (@f) {

  open(A,$i);
  open(B,"|sort > $i.2");

  while (<A>) {
    chomp;
    my($mtime,$size,$inode,$perm,$type,$gname,$uname,$devno,$name) = 
      split(/\s+/, $_, 9);

    if ($size < 1000000) {next;}

    # ignore directories, sockets, pipes, character/block devices + symlinks
    if ($type=~/^[dspcbl]$/) {next;}

    # if I decide to use mtime, snip off decimals
    $mtime=~s/\..*$//;

    # split into dir and pure filename
    $name=~s%^(.*)/(.*?)$%%;
    my($dir,$file) = ($1,$2);

    # joining (using mtime for now, but may drop)
    # the dir is not part of the join condition
    print B "$size $mtime $file\0$dir\n";
  }

  close(A);close(B);
}

system("join --check-order -t '\\0' local.txt.2 remote.txt.2 > joined.txt");

open(A,"joined.txt");

while (<A>) {
  chomp;

  my($fdata,$d1,$d2) = split(/\0/,$_);

  # get filename
  $fdata=~s/^\d+ \d+ //;

  # if source no longer exists, ignore
  unless (-f "$d1/$fdata") {next;}

  # change d2 to match d1 (TODO: don't hardcode this)
  $d2=~s%/Volumes/[A-Z]+/%/mnt/extdrive/%;

  # does this directory exist? (if not, create it)
  unless (-d $d2) {print "sudo mkdir -p \"$d2\"\n";}

  # does target exist ("mv -n" checks this, but its useful to check here too)
  if (-f "$d2/$fdata") {next;}

  print "sudo mv -n \"$d1/$fdata\" \"$d2/\"\n";
}

