#!/bin/perl

# Converts
# http://snap.nal.usda.gov/nutrition-through-seasons/holiday-observances
# (local copy in this directory) to iCalendar format
# actually to format for gcal first

require "/usr/local/lib/bclib.pl";

open(A,">$bclib{githome}/BCINFO3/sites/data/calendar/bcusda-test.ics");
print A << "MARK";
BEGIN:VCALENDAR\r
VERSION:2.0\r
PRODID: -//barrycarter.info//bc-usda.pl//EN\r
MARK
;

# months hash
for $i (1..12) {$months{$months[$i]}=$i;}

# regex
my($reg) = join("|",@months[1..12]);

# deordinalize
my(%ord) = ("first" => 1, "second" => 2, "third" => 3, "fourth" => 4);

debug("REG: $reg");

my($all) = read_file("$bclib{githome}/CALENDAR/holiday-observances.html");

# fixed dates
while ($all=~s%<li>(.*?)\s*\((.*?)\).%%) {

  # split into event and date
  my($ev,$da)=($1,$2);

  # ignore variable (non-computable) events
  if ($da=~/varies/i) {
    debug("IGNORING VARIABLE: $ev/$da");
    next;
  }

  $ev=~s/\&amp\;/&/g;

  # required by format
  my($uid) = sha1_hex("$da $day $ev barrycarter");

  # week long events
  if ($da=~s/^(.*?)\s+week\s+of\s+($reg)$//is) {
    my($ord,$mon) = ($1,$2);
    my($dtstart) = sprintf("2015%02d01T000000",$months{$mon});
    debug("WEEK: $ord/$mon");
# TODO: this creates a spurious event on 1 Jan 2015
    print A << "MARK";
BEGIN:VEVENT\r
SUMMARY:$ev\r
UID:$uid\r
DTSTART:20150101T000000\r
RRULE:FREQ=MONTHLY;BYMONTH=$months{$mon};BYDAY=$ord{$ord}SU\r
DURATION:P1W\r
END:VEVENT\r
MARK
;
    next;
  }

  # TODO: don't actually ignore non-dates, just for now

  # if date does not end in number, ignore
  unless ($da=~s/\s*(\d+)$//) {
    debug("SKIPPING: $ev/$da");
    next;
  }


  my($day) = $1;

  # if what remains is not a month, ignore
  unless ($months{$da}) {
    debug("SKIPPING: $ev/$da");
    next;
  }

  # cleanup
  my($dtstart) = sprintf("2015%02d%02dT000000",$months{$da},$day);

# TODO: this doesn't work yet, use RECUR rule
  print A << "MARK";
BEGIN:VEVENT\r
SUMMARY:$ev\r
UID:$uid\r
DTSTART:$dtstart\r
DURATION: 1d\r
RRULE:FREQ=YEARLY;\r
END:VEVENT\r
MARK
;
}

print A "END:VCALENDAR\r\n";
close(A);


