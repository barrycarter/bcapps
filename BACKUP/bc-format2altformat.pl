#!/bin/perl

# Converts files on various devices to canonical names, with size and mtime

# my devnos:

# 2080 = /mnt/extdrive
# 64768 = /
# 234881026 = /mnt/sshfs3/
# 234881029 = /mnt/sshfs/
# 2886150081 = /mnt/sshfs2/c/
# 3154434839 = /mnt/sshfs2/k/

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;

  my($mtime,$size,$inode,$perm,$type,$gname,$uname,$devno,$name) = 
    split(/\s+/, $_, 9);

  # recognized types I want to ignore
  if ($type=~/^[dspcb]$/) {next;}

  # ignore nonfiles/links
  unless ($type=~/^[fl]$/) {warn "BAD TYPE: $_"; next;}

  # edit filename based on devno
  if ($devno == 64768) {
    # do nothing, but not an error
  } elsif ($devno == 234881026) {
    $name = "/mnt/sshfs3$name";
  } elsif ($devno == 234881029) {
    $name=~s%/Volumes/[A-Z]{5}/%/mnt/sshfs/%;
  } elsif ($devno == 2886150081 || $devno == 3154434839) {
    $name=~s%/cygdrive/%/mnt/sshfs2/%;
  } else {
    warn("BAD DEVNO: $_");
    next;
  }

  # pad mtime to 11 characters so numerical sort == standard sort
  # (this is useful so I don't have to sort twice when using comm)
  $mtime = sprintf("%0.11d", $mtime);

  # for `join`, treat extension as separate field (or add null extension)
  unless ($name=~s/\.([^\.\/]*)$/\0$1/) {$name="$name\0";}

  # `join` on mtime and filename sans extension
  print "$mtime $name\0$size\n";
}
