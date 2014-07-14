#!/bin/perl

# Fun w/ meetup.com's API

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

my($out,$err,$res) = cache_command2("curl 'https://api.meetup.com/2/open_events?&sign=true&photo-host=public&zip=87101&radius=35&limited_events=1&page=2000&key=$private{meetup}{key}'", "age=3600");

%hash = %{JSON::from_json($out)};

for $i (@{$hash{results}}) {
  debug("I: $i",unfold($i));
  print strftime("%a %H%M\t$i->{name}\t$i->{group}{name}\t$i->{yes_rsvp_count}\n",localtime($i->{time}/1000));
#  debug("URL: $i->{name}, $i->{time}");
}

# debug("OUT: $out");
