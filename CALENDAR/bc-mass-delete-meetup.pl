#!/bin/perl

# oneoff to mass delete things I created by accident on meetup.com

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

my($out,$err,$res) = cache_command2("curl 'http://api.meetup.com/Albuquerque-Multigenerational-Center-Events-unofficial/upcoming.ical'","age=0");

while ($out=~s/UID:event_(\d+)\@//) {
  print "curl -X DELETE https://api.meetup.com/2/event/$1?key=$private{meetup}{key}\n";
}
