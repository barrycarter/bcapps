#!/bin/perl

# find sun/moon rise/set + twilight times for all airports for a given day
require "/usr/local/lib/bclib.pl";
use Astro::Nova;

# observer and current date
my($observer) = Astro::Nova::LnLatPosn->new();
my($jd) = Astro::Nova::get_julian_from_sys()-0.5;
$now = time();

@res = sqlite3hashlist("SELECT * FROM stations","/home/barrycarter/BCGIT/db/stations.db");

for $i (@res) {
  $observer->set_lat($i->{latitude});
  $observer->set_lng($i->{longitude});
#  debug("OB:",$observer->get_lat());
  $rst = Astro::Nova::get_solar_rst($jd, $observer);
  ($rise,$set) = (Astro::Nova::get_timet_from_julian($rst->get_rise()),
		  Astro::Nova::get_timet_from_julian($rst->get_set()));
  $rst2 = Astro::Nova::get_lunar_rst($jd, $observer);
  ($mrise,$mset) = (Astro::Nova::get_timet_from_julian($rst2->get_rise()),
		  Astro::Nova::get_timet_from_julian($rst2->get_set()));

  $loc = "$i->{city}, $i->{country}";
  if (abs($rise-$now) < 60) {
    print "$loc $rise RISE\n";
  } elsif (abs($set-$now) < 60) {
    print "$loc $set SET\n";
  } elsif (abs($mset-$now) < 60) {
    print "$loc $mset MSET\n";
  } elsif (abs($mrise-$now) < 60) {
    print "$loc $mrise MRISE\n";
  } else {
    # do nothing
  }

#  print "$i->{metar} $rise $set\n";
}


