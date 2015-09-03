#!/bin/perl

# Converts
# http://snap.nal.usda.gov/nutrition-through-seasons/holiday-observances
# (local copy in this directory) to iCalendar format
# actually to format for gcal first

require "/usr/local/lib/bclib.pl";

open(A,">$bclib{githome}/BCINFO3/sites/data/calendar/bcusda.ics");
print A << "MARK";
BEGIN:VCALENDAR\r
VERSION:2.0\r
PRODID: -//barrycarter.info//bc-usda.pl//EN\r
MARK
;

# months hash
for $i (1..12) {$months{$months[$i]}=$i;}

my($all) = read_file("$bclib{githome}/CALENDAR/holiday-observances.html");

# fixed dates
while ($all=~s%<li>(.*?)\s*\((.*?)\).%%) {

  # split into event and date
  my($ev,$da)=($1,$2);

  # TODO: don't actually ignore non-dates, just for now

  # if date does not end in number, ignore
  unless ($da=~s/\s*(\d+)$//) {next;}
  my($day) = $1;
  debug("DAY: $day");

  # if what remains is not a month, ignore
  unless ($months{$da}) {next;}

  # required by format
  my($uid) = sha1_hex("$da $day $ev barrycarter");

  # cleanup
  my($dtstart) = sprintf("2015%02d%02dT000000",$months{$da},$day);
  debug("DTS: $dtstart");


# TODO: this doesn't work yet, use RECUR rule
  print A << "MARK";
BEGIN:VEVENT\r
SUMMARY:$ev\r
UID:$uid\r
DTSTART:$dtstart
RRULE:FREQ=YEARLY;
END:VEVENT\r
MARK
;
}

print A "END:VCALENDAR\r\n";
close(A);


