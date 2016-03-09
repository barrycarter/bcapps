#!/bin/perl

# http://webapps.stackexchange.com/questions/90641/icalendar-rrule-recurring-events-custom-repeat?noredirect=1#comment79508_90641

=item answer

While there are several iCal creators online, I dont think any of
them will handle the complexity of the rules you need, especially the
first one.

Similarly, although RRULE is a nice tool, it cant do
everything. Sometimes, you just have to specify the dates yourself.

TODO: tell check my results

TODO: how to use template

TODO: put on sharecal?

TODO: note my choice of start dates

=cut

require "/usr/local/lib/bclib.pl";

# TODO: assuming here 2016-2038; would have to tweak beyond end of unix time

# TODO: assuming first day is 01 Feb 2016, but can tweak

$first = str2time("20160201 UTC");
my(@dates) = ($first);

# TODO: jump out of this loop at some point
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



=item list2ical(\@list)

Given a list of dates in unixtime format, return a string thats a
blank iCal with these dates.

=cut

sub list2ical {
  my($listref) = @_;

  # will return join of @str at end
  my(@str) = ("BEGIN:VCALENDAR", "VERSION:2.0", 
    "PRODID: -//barrycarter.info//bc-blank-ical-CHANGE-THIS//EN");

  for $i (@$listref) {
    my($tdate) = strftime("%Y%m%d", gmtime($i));

    # TODO: this is a pretty silly (and inefficent) way to get a
    # "random" hash, fix it

    my($out, $err, $res) = cache_command2("dd if=/dev/urandom count=1 | sha1sum", "age=-1");
    $out=~s/\s.*$//sg;

    my($event) = << "MARK";
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
  return(join("\n",@str));
}


