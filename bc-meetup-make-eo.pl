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

$cmd = "curl -X PATCH 'https://api.meetup.com/$gurl/members/219789953' -d 'add_role=event_organizer&key=$private{meetup}{key}'";

for $i (@arr) {

  # ignore people who already have roles
  if ($i->{group_profile}{role}) {next;}

  $cmd = "curl -X PATCH 'https://api.meetup.com/$gurl/members/$i->{id}' -d 'add_role=event_organizer&key=$private{meetup}{key}'";

  # as part of my plan to never actually run anything, just print
  print "$cmd\n";

}
