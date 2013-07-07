#!/bin/perl

# bc-walkaround.pl has an error that sometimes puts tomorrow's replies
# into today's "diary" file (if the alert occurs before midnight, but
# the reply occurs after midnight). This attempts to fix those diary
# files where this occurs

require "/usr/local/lib/bclib.pl";

# TODO: look through older files as well... this subset for testing only

for $i (glob "/home/barrycarter/TODAY/201306*.txt") {
  $lastreading = 0;
  open(A,$i)||die("Can't open $i, $!");
  while (<A>) {
    chomp;
    # ignore blanks
    if (/^\s*$/) {next;}
    # just the timestamp, delete the rest
    s/\s+.*$//;
    unless ($_ > $lastreading) {
      die("OUT OF ORDER($i): $_ <= $lastreading");
    }

    $lastreading = $_;
  }

  close(A);
}
