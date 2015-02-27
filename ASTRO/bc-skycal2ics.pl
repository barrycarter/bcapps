#!/bin/perl

# converts the SKYCAL calendars from NASA to ICS format

require "/usr/local/lib/bclib.pl";

# month 3-letter abbrev to number
my(%months);
for $i (0..$#months) {$months{substr($months[$i],0,3)} = sprintf("%02d",$i);}

my($month);

open(A,">$bclib{githome}/BCINFO3/sites/data/calendar/bcimpdates.ics");

print A << "MARK";
BEGIN:VCALENDAR\r
VERSION:2.0\r
PRODID: -//barrycarter.info//bc-skycal2ics.pl//EN\r
DESCRIPTION:This ical file contains every event listed in http://eclipse.gsfc.nasa.gov/SKYCAL/SKYCAL.html, with all options checked, for 2015-2037, a total of 6299 events over 23 years (about 274 events per year). This includes moon phases, eclipses, equinoxes/solstices, apogee/perigee, lunar/planetary/solar conjuctions, maximum elongations, ascending/descending node, meteor showers and more. For most people this will overkill, and you will want to filter.\r
MARK
;

# flat format for bc-calendar.pl (but probably won't work, too wide)
open(B,">$bclib{home}/calendar.d/skycal.txt");

for $i (glob "$bclib{githome}/ASTRO/SKYCAL*.html") {

  # figure out year
  $i=~/(\d{4})\.html/;
  my($year) = $1;

  my($all) = read_file($i);

  while ($all=~s%<tr>(.*?)</tr>%%s) {
    my($row) = $1;
    # $x is normally &nbsp; but is month heading otherwise
    my($x, $date, $wday, $time, $event) = ($row=~m%<td.*?>(.*?)</td>%sg);

    # special case because July breaks in middle of month
    if ($x=~/^\s*$/) {next;}

    # new month
    unless ($x eq "&nbsp;") {$month = $months{$x};}

    # cleanup
    $date=~s/\D//g;
    # if no time defined, pretend middle of day
    unless ($time) {$time="12:00";}
    $time=~s/://g;
    # no XML/HTML inside events
    $event=~s/<.*?>//g;

    # TODO: add categories based on event type

    # format time
    my($ftime) = "$year$month${date}T${time}00Z";

    # artificial
    my($uid) = sha1_hex("$event $time");

    # TODO: for lunar eclipses, note the day before (which can be
    # wrong, but safer than day late) [or be clever and only go day
    # early if needed?, eg if mid-eclipse > noon local, same day]


    # for my bc-calendar.pl, space is limited, so filter and shorten
    $event2 = shorten($event,$time);
    if ($event2) {print B "$year$month$date $event2\n";}

print A << "MARK";
BEGIN:VEVENT\r
SUMMARY:$event\r
UID:$uid\r
DTSTART:$ftime\r
DTEND:$ftime\r
END:VEVENT\r
MARK
;

  }
}

print A "END:VCALENDAR\r\n";

close(A); close(B);

# program-specific subroutine to shorten event for bc-calendar.pl

sub shorten {
  my($event,$time) = @_;
  debug("$event/$time");

  # odd character that causes problems
  $event=~s/\xc2//g;

  # uninteresting planets
  if ($event=~/neptune|pluto/i) {return;}

  # apoapsis/periapsis uninteresting to me
  if ($event=~/(apo|peri)(gee|helion)/i) {return;}
  # I handle moon phases in bc-calendar.pl directly
  if ($event=~/(full|new) moon/i || $event=~/(first|last) quarter/i) {return;}
  # node crossings uninteresting
  if ($event=~/moon (asc|desc)ending node/i) {return;}
  # max north/south also uninteresting
  if ($event=~/moon (nor|sou)th/i) {return;}

  # TODO: adjust date if event is on prev day in my tz
  # eclipse abbreviation
  if ($event=~/(partial|total) (lunar|solar) eclipse/i) {
    return lc($2)." eclipse";
  }

  # remove word elongation and odd spaces
  if ($event=~s/elongation//i && $event=~s/ : /: /g) {return $event;}

  # TODO: I want these back, this elimination is only temporary
  if ($event=~/^moon\-/i) {return;}

  # adding astericks for now so I can identify unchanged events
  return "*$event*";
}
