#!/bin/perl

# converts files into "tar tv --utc" format into backup-compatible
# exclusion filse with lines like:
# file<TAB>mtime

# the newer version does NOT use conversions, those are all handled at
# the "dupes" level; it also won't work if filenames have tabs in
# them, but thats just plain weird

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;

  my($perms, $owner, $size, $date, $time, $name) = split(/\s+/,$_,6);

  $name = "/$name";

  # convert \xxx to octal character

  $name=~s/\\(\d+)/chr(oct($1))/seg;

  $mtime = str2time("$date $time UTC");
  print "$name\t$mtime\n";
}

# output should be sorted so I can use "sort -mu" when combining
