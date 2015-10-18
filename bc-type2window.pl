#!/bin/perl

# uses xdotool to type lines in a file to a window, but in a way that
# does trigger "flood" warnings

require "/usr/local/lib/bclib.pl";

while (<>) {
  chomp;

  for $i (split(//,$_)) {print xdotoolkey($i);}
  print "xdotool key Return\n";
}


sub xdotoolkey {
  my($key) = @_;

  # quote key
  if ($key eq "'") {$key=qq%"'"%;} else {$key="'$key'";}

  # special case
#  if ($key eq " ") {$key="Space";}

  # using system sleep (not Perl sleep) for hopefully more consistency
  # the sleep post-keyup so next xdotool command is delayed
  return "xdotool type $key; sleep 0.10\n";
}
