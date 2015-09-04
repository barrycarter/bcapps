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
my(%ord) = ("first"=>1,"second"=>2,"third"=>3,"fourth"=>4,"last"=>-1);

debug("REG: $reg");

my($all) = read_file("$bclib{githome}/CALENDAR/holiday-observances.html");

# fixed dates
while ($all=~s%<li>(.*?)\s*\((.*?)\).%%) {

  # split into event and date
  my($ev,$da)=($1,$2);

  # ignore variable (non-computable) events
  if ($da=~/varies|changes/i) {
    debug("IGNORING VARIABLE: $ev/$da");
    next;
  }

  $ev=~s/\&amp\;/&/g;

  # required by format
  my($uid) = sha1_hex("$da $day $ev barrycarter");

  # TODO: "last week in April"/etc I probably have wrong
  # week long events or events on nth weekday of month
  debug("DA: $da");
  if ($da=~s/^(.*?)\s+(.*?)\s+(of|in)\s+($reg)$//is) {
    my($ord,$wday,$mon) = ($1,$2,$4);

    # duration is 1 day, unless a week
    my($duration) = "P1D";

    # fixup the ordinal
    $ord = $ord{lc($ord)};
    # and the month
    $mon = $months{$mon};
    # and the weekday
    if ($wday=~/week/) {$wday="Sunday"; $duration="P1W";}
    $wday = uc(substr($wday,0,2));

    debug("W: -> $ord|$wday|$mon");
#    my($dtstart) = sprintf("2015%02d01T000000",$months{$mon});

# TODO: this creates a spurious event on 1 Jan 2000
    print A << "MARK";
BEGIN:VEVENT\r
SUMMARY:$ev\r
UID:$uid\r
DTSTART:20000101T000000\r
RRULE:FREQ=MONTHLY;BYMONTH=$mon;BYDAY=$ord$wday\r
DURATION:$duration\r
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
DTSTART:20000101T000000\r
DURATION: P1D\r
RRULE:FREQ=YEARLY;BYMONTH=$months{$da};BYDAY=$day\r
END:VEVENT\r
MARK
;
}

print A "END:VCALENDAR\r\n";
close(A);


