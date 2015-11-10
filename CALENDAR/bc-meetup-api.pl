#!/bin/perl

# this program, unlike ../bc-meetup.pl, uses the Meetup API to
# schedule events, more specifically, events held at the
# Multigenerational centers in the City of Albuquerque

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

my($url) = "https://api.meetup.com/2/event";

my($postdata) = "group_urlname=Albuquerque-Multigenerational-Center-Events-unofficial&name=Please+Ignore+This+Test+Event+1557&key=$private{meetup}{key}&duration=3600000&guest_limit=999&publish_status=draft&time=1447592400000&venue_visibility=public&venue_id=710375";

my($out,$err,$res) = cache_command("curl -d '$postdata' '$url'","age=1800");

debug("OUT: $out\nERR: $err");

