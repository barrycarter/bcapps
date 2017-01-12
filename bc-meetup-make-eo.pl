#!/bin/perl

# uses meetup's API to make everyone in one of my groups an event
# organizer (see
# https://www.meetup.com/help/customer/portal/articles/868742-who-can-add-meetups-/
# for why this is necessary)

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# this is the group URL, can probably get group number if I want it,
# but not needed?

my($gurl) = "Socially-Awkward-People-Want-to-Socialize-SAPWWS";

my($cmd) ="curl 'https://api.meetup.com/$gurl/members?key=$private{meetup}{key}'";

# TODO: 86400 for testing only
my($out,$err,$res) = cache_command2($cmd, "age=86400");

my(@arr) = @{JSON::from_json($out)};

# purely test command to flip fake user event organizer credentials to
# confirm no email is sent

$cmd = "curl -X PATCH 'https://api.meetup.com/$gurl/members/219789953&key=$private{meetup}{key}&sign=true' -d 'add_role=event_organizer'";

$cmd = "curl -X PATCH 'https://api.meetup.com/$gurl/members/219789953&key=$private{meetup}{key}&sign=true'";

$cmd = "curl -X PATCH 'https://api.meetup.com/$gurl/members/219789953' -d 'add_role=event_organizer&key=$private{meetup}{key}'";

debug("CMD: $cmd");


die "TESTING";

for $i (@arr) {

  # ignore people who already have roles
  if ($i->{group_profile}{role}) {next;}

}

die "TESTING";

my(%hash) = JSON::from_json($out);

debug(dump_var("ALPHA", JSON::from_json($out)));
