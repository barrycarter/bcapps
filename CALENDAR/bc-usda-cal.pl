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

# days that gcal already lists
my(%known) = list2hash("Independence Day", "New Year's Day");

my($all) = read_file("$bclib{githome}/CALENDAR/holiday-observances.html");

# fixed dates
while ($all=~s%<li>(.*?)\s*\((.*?)\).%%) {

  # split into event and date
  my($ev,$da)=($1,$2);

  # TODO: don't actually ignore non-dates, just for now

  # if date does not end in number, ignore
  unless ($da=~s/\s*(\d+)$//) {next;}
  my($day) = $1;

  # if what remains is not a month, ignore
  unless ($months{$da}) {next;}

  # if already listed holiday, ignore
  if ($known{$ev}) {next;}

  # print a "basic" form of the holiday for grepping
  my($grep) = $ev;
  $grep=~s/\b(day|of|the|\&amp\;)\b//isg;
  $grep = lc($grep);
  $grep=~s/\s+/ /sg;
  $grep=~s/^\s+//sg;
  $grep=~s/\s+$//sg;

  # print this so I can confirm I am not repeating stuff sort of
  print "$grep\n";

#  debug("GRE: $grep");

  debug("GOT: $da|$day|$ev");
}

