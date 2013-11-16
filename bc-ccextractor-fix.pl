#!/bin/perl

# Given ccextractor output removes redundant lines and timestamps to
# provide just a text dump

require "/usr/local/lib/bclib.pl";
my($data) = cmdfile();

for $i (split(/\n/,$data)) {
  # remove \r
  $i=~s/\s*$//;
  # is this a frame number? if so, advance frame count
  if ($i=~/^(\d+)$/ && $1 == $frame+1) {$frame++; next;}
  # is this an SRT time line? if so, ignore
  if ($i=~/^[\d\:\,]+ \-\-> [\d\:\,]+$/) {
    debug("SRT TIME: $i");
    next;
  }

  # if I've seen this line less than 3 frames ago, ignore it
  # TODO: this will kill off true duplicate sentences, need to fix
  if ($seen{$i} && $seen{$i} > $frame-3) {
    debug("SEEN: $i");
    next;
  }

  print "$i\n";
  $seen{$i} = $frame;
}



