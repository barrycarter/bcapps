#!/bin/perl

# http://webapps.stackexchange.com/questions/90641/icalendar-rrule-recurring-events-custom-repeat?noredirect=1#comment79508_90641

=item answer

To clarify, I meant write a program that creates an iCalendar, but
lists dates explicitly instead of using an RRULE.

While there are several iCal creators online, I dont think any of
them will handle the complexity of the rules you need, especially the
first one.

You might find an RRULE for your second condition, but I found it
easier to simply write a program.

Overall, although RRULE is a nice tool, it cant do
everything. Sometimes, you just have to specify the dates yourself,
which also gives you more flexibility to use other calendar formats
which may not support RRULE.

Ive now written:

https://github.com/barrycarter/bcapps/blob/master/STACK/bc-blank-ical.pl

and created these blank iCalendars per your date rules above.

http://oneoff.barrycarter.info/webapps-90641-1.ics

http://oneoff.barrycarter.info/webapps-90641-2.ics

Important notes:

  - Be sure to check my work: make sure the dates in the calendar are
  the dates you actually want.

  - For your first rule, I arbitrarily assumed the first event was on
  February 1st. You should tweak my program to generate the correct
  date (or contact me (see profile), and I can do this).

  - For your second rule, I created events from 2016 through 2037
  inclusive.

  - To use these calendars, search/replace all instances of _SUMMARY_
  with the actual summary of your event, all instances of
  _DESCRIPTION_ with the description, and so on. The calendars I
  created only have dates and randomly generated UIDs.

  - You should also change the PRODID of each calendar.

While I personally dont object, Im not sure this question actually
belongs on webapps, since its not about an existing web application.

=cut

require "/usr/local/lib/bclib.pl";

# TODO: assuming here 2016-2038; would have to tweak beyond end of unix time

# TODO: assuming first day is 01 Feb 2016, but can tweak

$first = str2time("20160201 UTC");
my(@dates) = ($first);

for (;;) {

  # add 30 days
  $first += 30*86400;

  if ($first > 2**31) {last;}

  # check day of week
  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($first);

  # if its saturday, add two days; sunday, add one day
  if ($wday == 6) {
    $first += 86400*2;
  } elsif ($wday == 0) {
    $first += 86400;
  }

  push(@dates,$first);
}

write_file(list2ical(\@dates), "/tmp/file1.txt");

# NOTE: this does the literal example in the question, but can be tweaked

my(@dates) = ();

for $y (2016..2037) {
  for $m ("01".."12") {
    my($date) = str2time("$y${m}15 UTC");
    my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime($date);

    # if the 15th is MTW, 3 weekdays ago = 5 days ago
    # if its RF(sat) 3 weekdays = 3 calendar days
    # if its sunday, 4 days ago

    if ($wday >= 1 && $wday <= 3) {
      $date -= 5*86400;
    } elsif ($wday == 0) {
      $date -= 4*86400;
    } else {
      $date -= 3*86400;
    }

    push(@dates, $date);
  }
}

write_file(list2ical(\@dates), "/tmp/file2.txt");

=item list2ical(\@list)

Given a list of dates in unixtime format, return a string thats a
blank iCal with these dates.

=cut

sub list2ical {
  my($listref) = @_;

  # will return join of @str at end
  my(@str) = ("BEGIN:VCALENDAR", "VERSION:2.0", 
    "PRODID: -//barrycarter.info//bc-blank-ical-CHANGE-THIS//EN", "");

  for $i (@$listref) {
    my($tdate) = strftime("%Y%m%d", gmtime($i));

    # TODO: this is a pretty silly (and inefficent) way to get a
    # "random" hash, fix it

    my($out, $err, $res) = cache_command2("dd if=/dev/urandom count=1 | sha1sum", "age=-1");
    $out=~s/\s.*$//sg;

    my($event) = << "MARK";
BEGIN:VEVENT
SUMMARY: _SUMMARY_
UID: $out
DTSTART: ${tdate}T000000
DTEND: ${tdate}T235959
LOCATION: _LOCATION_
DESCRIPTION: _DESCRIPTION_
COMMENT: _COMMENT_
END:VEVENT
MARK
;
   push(@str, $event);
}

  push(@str, "END:VCALENDAR");
  my($str) = join("\n",@str);
  $str=~s/\n/\r\n/g;
  return $str;

}


