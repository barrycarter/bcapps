#!/bin/perl

require "/usr/local/lib/bclib.pl";

my($all) = read_file("$bclib{githome}/CALENDAR/impdates.html");

#debug("ALL: $all");

while ($all=~s%<tr>(.*?)</tr>%%is) {
  my($event) = $1;
#  debug("EVENT: $event");
  my(@data) = ($event=~m%<td.*?>(.*?)</td>%isg);

  for $i (@data) {
    # remove HTML and trim/fix newlines (vcalendar should be ok w that)
    $i=~s/<.*?>//g;
    $i=~s/^\s*//;
    $i=~s/\s*$//;
    $i=~s/\n/\\n/g;
    # ugly
    $i=~s/[^ -~]//g;
    # uglier
    $i=~s/\&\#\d+\;//g;
    # per Emilie request
    $i=~s/international/worldwide/g;
  }
  print join("|",@data),"\n";
}

