#!/bin/perl

# converts the SKYCAL calendars from NASA to ICS format

require "/usr/local/lib/bclib.pl";

# month 3-letter abbrev to number
my(%months);
for $i (0..$#months) {$months{substr($months[$i],0,3)} = sprintf("%02d",$i);}

my($month);

debug(%months);

print << "MARK";
BEGIN:VCALENDAR\r
VERSION:2.0\r
PRODID: -//barrycarter.info//bc-skycal2ics.pl//EN\r
DESCRIPTION:This ical file contains every event listed in http://eclipse.gsfc.nasa.gov/SKYCAL/SKYCAL.html, with all options checked, for 2015-2037, a total of 6299 events over 23 years (about 274 events per year). This includes moon phases, eclipses, equinoxes/solstices, apogee/perigee, lunar/planetary/solar conjuctions, maximum elongations, ascending/descending node, meteor showers and more. For most people this will overkill, and you will want to filter.\r
MARK
;

# flat format for bc-calendar.pl (but probably won't work, too wide)
open(B,">/tmp/skycal.txt");

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

    # keeping event pure for ics, but omitting bad char for bc-calendar
    $event2 = $event;
    $event2=~s/\xc2//;

    print B "$year$month$date $event2\n";

print << "MARK";
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

print "END:VCALENDAR\r\n";

close(B);


