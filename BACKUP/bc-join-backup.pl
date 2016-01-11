#!/bin/perl

# Given the output of 'join -a 1 -t '\0' afad.txt
# previouslydone.txt.srt', do... something

# TODO: egrep -avf exclusions.txt after join, pre running this prog?
# TODO: can actually sort by second field first so only doing most recent

require "/usr/local/lib/bclib.pl";

while (<>) {

  chomp;
  my($canon, $mtime, $origname, $size, $backtime) = split(/\0/, $_);

  # if the backup time is more recent, do nothing
  if ($backtime >= $mtime) {next;}

  # in all other cases, print for bc-chunk-backup2.pl
  # note that bc-chunk-backup2.pl will ignore mtime
  print join("\0", $mtime, $origname, $size),"\n";
}


