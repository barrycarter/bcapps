#!/bin/perl

# sieves interesting events from http://www.jpl.nasa.gov/calendar/

require "/usr/local/lib/bclib.pl";

# list of words we want ("Earth" is intentionally excluded below)
$wanted = join("|", ("mercury","venus","mars","jupiter","saturn","uranus","neptune","pluto","meteor","moon","sun","equinox","eclipse","solstice","daylight"));

# list of words we don't want
$unwanted = join("|", ("conference","society","symposium","lecture","anniversary","insertion","flyby","workshop","thinkshop","mission","moonbuggy","sun\-earth","craters","baryons","webcast","cassini","utsunomiya","odyssey","deadline","ariane","apollo","beagle","rover","messenger","penetrator","inmarsat","octagon","tsyklon","international meeting","launch","spaceops","orbiter","venus express","marsden", "anniversary"));

my($out,$err,$res) = cache_command2("curl -L http://www.jpl.nasa.gov/calendar/","age=86400");

# determine short list of months
my($regex) = "^(".join("|",map($_=substr($_,0,3), @months[1..12])).") ";

for $i (split(/\s*<li>\s*/,$out)) {

  # ignore things not matching months
  unless ($i=~/$regex/) {warn("NO MATCH: $i"); next;}

  # separate into date(s) and event
  my($date, $event) = split(/\s+\-\s+/, $i);
  debug("ALPHA: $date/$event");
  next;
warn "TESTING";

  # identify the event
  unless ($i=~s%<a href.*?>(.*?)</a>%%) {
    warn "NO EVENT: $i";
    next;
  }

  my($event) = $1;

  debug("I: $1");

}
