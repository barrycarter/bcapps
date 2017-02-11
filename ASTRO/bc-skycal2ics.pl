#!/bin/perl

# converts the SKYCAL calendars from NASA to ICS format

require "/usr/local/lib/bclib.pl";

# month 3-letter abbrev to number
my(%months);
for $i (0..$#months) {$months{substr($months[$i],0,3)} = sprintf("%02d",$i);}

my($month);

open(A,">$bclib{githome}/BCINFO3/sites/data/calendar/skycal.ics");

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

    # ACK! Per comment to http://icalshare.com/calendars/6954 this was
    # not unique -- full moon or whatever can occur at same time
    # creating duplicate key; tweaked

    # artificial
    my($uid) = sha1_hex("$ftime $event");

    # TODO: for lunar eclipses, note the day before (which can be
    # wrong, but safer than day late) [or be clever and only go day
    # early if needed?, eg if mid-eclipse > noon local, same day]


    # for my bc-calendar.pl, space is limited, so filter and shorten
    print B shorten($event,$ftime);

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

  # alert for lunar eclipses 12 hours in advance (ie, previous day)
  my($stardate);
  if ($event=~/lunar eclipse/i) {
    $stardate = strftime("%Y%m%d.%H%M", localtime(str2time($time)-43200));
  } else {
    $stardate = strftime("%Y%m%d.%H%M", localtime(str2time($time)));
  }

  my($sdate,$stime) = split(/\./, $stardate);

  # odd character that causes problems
  $event=~s/\xc2//g;

  # kill space after degrees
  $event=~s/\xb0\s+/\xb0/g;

  # calendar includes Venus position start of each month, but I don't need this
  if ($event=~/venus: \d/i) {return;}

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

  # eclipse abbreviation
  $event=~s/(partial|total|annular|pen\.|hybrid) (lunar|solar)/$2/i;

  # remove word elongation and odd spaces
  if ($event=~s/elongation//i) {
    $event=~s/ :/:/;
    $event=~s/E/eve/;
    $event=~s/W/morn/;
  }

  # for equinoxes/solstices, add time and remove type
  $event=~s/^.*?\s+(equinox|solstice)/$1 ($stime)/i;

  # shrink planet names + more
  $event=~s/(mercury|venus|earth|mars|jupiter|saturn|uranus|beehive|pollux|pleiades|aldebaran|superior|inferior|conj\.|conjunction|regulus|antares)/substr($1,0,3)/ieg;

  # convert inferior/superior conjunction to something more useful
  $event=~s/inf con/-> mor*/i;
  $event=~s/sup con/-> eve*/i;

  # solar conjunctions are just listed as Conjunction (which I shorted
  # to Con), fixing here

  # NOTE: when Saturn conjuncts the sun, this yields a confusing
  # "Sat-Sun", but I'm ok w/ that [eg, 29 Nov 2015, which happens to
  # be a Sunday]
  $event=~s/ Con/-Sun/;

  # short form for meteor showers
  $event=~s/(^.*?) Shower: ZHR = (\d+)/${1}s ($2\/hr)/;

  # others
  $event=~s/aquarids/Aqu/i;
  $event=~s/Quadrantids/Quadrntds/i;
#  $event=~s/regulus/Reglus/i;
#  $event=~s/antares/Antres/i;
  $event=~s/aphelion: /Sun-Ear: /i;
  $event=~s/South /S. /;
  $event=~s/North /N. /;

  # will cause probs for bc-calendar.pl
  if (length($event)>18) {warn("$event > 18 chars");}

  debug("EV: $event");

  return "$sdate $event\n";
}
