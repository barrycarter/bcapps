#!/bin/perl

# Trivial app to read ics files

require "/usr/local/lib/bclib.pl";

my($data, $filename) = cmdfile();

while ($data=~s/BEGIN:VEVENT(.*?)END:VEVENT//s) {
  my($event) = $1;

  my(%hash) = ();

  for $i ("dtstart", "dtend", "summary") {
    $event=~s/^($i.*)$//im;
    $hash{$i} = $1;
  }

  $hash{dtstart}=~s/^.*(\d{8}).*$/$1/ ||warn "BAD DATE: $hash{dtstart}";
  $hash{summary}=~s/summary://i;
  print "$hash{dtstart} $hash{summary}\n";

  # testing
#  unless ($hash{dtstart}=~/20140[89]/) {next;}

  debug("HASH",%hash);
}
