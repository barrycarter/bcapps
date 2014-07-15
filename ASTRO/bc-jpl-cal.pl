#!/bin/perl

# sieves interesting events from http://www.jpl.nasa.gov/calendar/

require "/usr/local/lib/bclib.pl";

# list of words we want ("Earth" is intentionally excluded below)
$wanted = join("|", ("mercury","venus","mars","jupiter","saturn","uranus","neptune","pluto","meteor","moon","sun","equinox","eclipse","solstice","daylight"));

# list of words we don't want
$unwanted = join("|", ("conference","society","symposium","lecture","anniversary","insertion","flyby","workshop","thinkshop","mission","moonbuggy","sun\-earth","craters","baryons","webcast","cassini","utsunomiya","odyssey","deadline","ariane","apollo","beagle","rover","messenger","penetrator","inmarsat","octagon","tsyklon","international meeting","launch","spaceops","orbiter","venus express","marsden", "anniversary"));

# moon phases currently unused
my($mout, $merr, $mres) = cache_command2("curl -L 'http://aa.usno.navy.mil/cgi-bin/aa_moonphases.pl?year=2014'", "age=86400");

debug("MOUT: $mout");

die "TESTING";

my($out,$err,$res) = cache_command2("curl -L http://www.jpl.nasa.gov/calendar/","age=86400");

# determine short list of months
my($regex) = "^(".join("|",map($_=substr($_,0,3), @months[1..12])).") ";

for $i (split(/\s*<li>\s*/,$out)) {
  # remove newlines
  $i=~s/\s+/ /isg;

  # determine year (and continue)
  if ($i=~s%<h2>[A-Z][a-z]+\s+(\d{4})</h2>%%) {$year = $1;}

  # ignore things not matching months
  unless ($i=~/$regex/) {warn("NO MATCH: $i"); next;}

  # separate into date(s) and event
  my($date, $event) = split(/\s+\-\s+/, $i, 2);

  # de-href the event
  $event=~s%<a href\=.*?>(.*?)</a>%$1%sg;

  # the order here is important, filter out unwanteds first
  if ($event=~/$unwanted/i) {next;}

  # TODO: this is imperfect
  if ($event=~/$wanted/i) {
    print "$date $year $event\n";
  }

#  debug("ALPHA: $date/$event");
}
