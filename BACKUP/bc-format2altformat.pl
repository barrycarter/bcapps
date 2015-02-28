#!/bin/perl

# converts file lists in standard format (see README) to "mtime size
# type filename" format, which is actually more useful for backups

require "/usr/local/lib/bclib.pl";

while (<>) {

  # $x = unwanted
  my($mtime,$size,$x,$raw,$x,$x,$name) = split(/\s+/, $_, 7);

  # figure out file type + replace w letter
  $raw = hex($raw);

  # must be a file, but not a socket
  # http://unix.stackexchange.com/questions/39716/what-is-raw-mode-in-hex-from-stat-output

  unless ($raw&32768 && !($raw&4096)) {next;}

  # pad mtime to 10 characters so numerical sort == standard sort
  # (this is useful so I don't have to sort twice when using comm)
  # <h>this may break in 2286 AD or so </h>
  $mtime = sprintf("%0.10d", $mtime);
  print "$mtime $size $name";
}
