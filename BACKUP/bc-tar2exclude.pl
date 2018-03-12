#!/bin/perl

# converts files into "tar tv --utc" format into backup-compatible
# exclusion filse with lines like:
# file\0mtime

# since we're starting fresh, no conversions required

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;

  my($perms, $owner, $size, $date, $time, $fname) = split(/\s+/,$_,6);

  $mtime = str2time("$date $time UTC");
  print "/$fname\0$mtime\n";
}
