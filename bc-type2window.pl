#!/bin/perl

# uses xdotool to type lines in a file to a window, but in a way that
# does trigger "flood" warnings

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;
  my($len) = length($_);
  my($delay) = $len/30;
  print "xdotool type \"$_\"\n";
  print "sleep $delay\n";
  print "xdotool key Return\n";
}


