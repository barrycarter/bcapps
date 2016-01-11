#!/bin/perl

# Given the output of 'join -a 1 -t '\0' afad.txt
# previouslydone.txt.srt', do... something

# TODO: egrep -avf exclusions.txt after join, pre running this prog?
# TODO: can actually sort by second field first so only doing most recent

require "/usr/local/lib/bclib.pl";

while (<>) {

  chomp;
  my($canon, $mtime, $origname, $size, $backtime) = split(/\0/, $_);

  if ($backtime>$mtime) {
    debug("ODD CASE: $backtime > $mtime",$_);
  }

#  debug("$mtime vs $backtime");

}

