#!/bin/perl

# converts file lists in standard format (see README) to "mtime size
# filename" format, which is actually more useful for backups

require "/usr/local/lib/bclib.pl";

while (<>) {
  # TODO: doing these conversions here is bad (but easier)
  s%/cygdrive/%/mnt/sshfs2/% || s%/Volumes/[A-Z]{5}/%/mnt/sshfs/% ||
     s%/%/mnt/sshfs3/%;

  # $x = unwanted
  my($size,$mtime,$x,$x,$x,$x,$name) = split(/\s+/, $_, 7);

  # pad mtime to 10 characters so numerical sort == standard sort
  # (this is useful so I don't have to sort twice when using comm)
  # <h>this may break in 2286 AD or so </h>
  $mtime = sprintf("%0.10d", $mtime);
  print "$mtime $size $name";
}


