#!/bin/perl

# Converts files on various devices to canonical names, with size and mtime

# my devnos:

# 2080 = /mnt/extdrive
# 64768 = /
# 234881026 = /mnt/sshfs3/
# 234881029 (also 234881028) = /mnt/sshfs/
# 2886150081 = /mnt/sshfs2/c/
# 3154434839 = /mnt/sshfs2/k/
# below is temporary for a special case external drive
# 2065/2161 = temp


require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;

  my($mtime,$size,$inode,$perm,$type,$gname,$uname,$devno,$name) = 
    split(/\s+/, $_, 9);

  # zpaq rounds mtime down to nearest second
  $mtime=~s/\..*$//;

  # because we want to sort highest mtimes first, use "negative mtime"
  # 33 below guarentees result is exactly 10 digits long, no padding required
  # (32 would probably work too)
  $mtime = 2**33-$mtime;

  # recognized types I want to ignore
  if ($type=~/^[dspcb]$/) {next;}

  # ignore nonfiles/links
  unless ($type=~/^[fl]$/) {warn "BAD TYPE: $_"; next;}

  # edit filename based on devno
  if ($devno == 64768) {
    # do nothing, but not an error
  } elsif ($devno == 234881026) {
    $name = "/mnt/sshfs3$name";
  } elsif ($devno == 234881028) {
    $name=~s%/Volumes/[A-Z]{5}/%/mnt/sshfs/%;
  } elsif ($devno == 2886150081 || $devno == 3154434839) {
    $name=~s%/cygdrive/%/mnt/sshfs2/%;
  } elsif ($devno == 2161) {
    $name=~s%^\.%%;
  } elsif ($devno == 2080) {
    # do nothing, but allow
  } else {
    warn("BAD DEVNO ($devno): $_");
    next;
  }

  # `join` on mtime and filename
  print "$mtime $name\0$size\n";
}
