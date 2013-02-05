#!/bin/perl

# find sun/moon rise/set + twilight times for all airports for a given day
require "/usr/local/lib/bclib.pl";
use Astro::Nova;

# observer and current date
my($observer) = Astro::Nova::LnLatPosn->new();
my($jd) = Astro::Nova::get_julian_from_sys();
debug("JD: $jd");

@res = sqlite3hashlist("SELECT * FROM stations LIMIT 3","/home/barrycarter/BCGIT/db/stations.db");

for $i (@res) {
  $observer->set_lat($i->{latitude});
  $observer->set_lng($i->{longitude});
  debug("OB:",$observer->get_lat());
  $rst = Astro::Nova::get_solar_rst($jd, $observer);
  debug("RST:", $rst->get_rise());
#  print "$i->{metar}",  $rst->get_rise(), $rst->get_set(), "\n";
}


