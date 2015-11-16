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
# 2065/2161/2225 = temp

# new extdrives (already use full path names in their dumps)

# these appear to change on reboot/remount, grrr
# TODO: automate updating these
# my(%drives) = ( 2096 => "/mnt/extdrive", 2065 => "/mnt/extdrive2",
# 2081 => "/mnt/extdrive3", 2113 => "/mnt/extdrive4" );

require "/usr/local/lib/bclib.pl";

warn "Rewriting feature disabled, original filenames used";

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

  # ZPAQ ignores links, so ignoring them here as well. This reduces
  # the *number* of entries massively, but has very little impact on
  # estimated size (since symlinks are tiny)

  # recognized types I want to ignore
  if ($type=~/^[dspcbl]$/) {next;}

  # ignore nonfiles
  unless ($type=~/^[f]$/) {warn "BAD TYPE: $_"; next;}

=item comment

commenting out this code because I no longer have sshfs mounted
drives, and drive numbers locally change on every remount which is
ugly.

  # edit filename based on devno
  if ($drives{$devno}) {
    # do nothing, already ok
  } elsif ($devno == 64768) {
    # do nothing, but not an error
  } elsif ($devno == 234881026) {
    $name = "/mnt/sshfs3$name";
  } elsif ($devno == 234881028) {
    $name=~s%/Volumes/[A-Z]{5}/%/mnt/sshfs/%;
  } elsif ($devno == 2886150081 || $devno == 3154434839) {
    $name=~s%/cygdrive/%/mnt/sshfs2/%;
  } elsif ($devno == 2225) {
    $name=~s%^\.%%;
  } elsif ($devno == 2080) {
    # do nothing, but allow
  } else {
    warn("BAD DEVNO ($devno): $_");
    next;
  }

=cut

  # `join` on mtime and filename
  print "$mtime $name\0$size\n";
}
