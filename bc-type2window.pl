#!/bin/perl

# uses xdotool to type lines in a file to a window, but in a way that
# doesn't trigger "flood" warnings

# -sleep: time to sleep between keystrokes (default 0)

require "/usr/local/lib/bclib.pl";
defaults("sleep=0");

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
  return "xdotool type $key; sleep $globopts{sleep}\n";
}
