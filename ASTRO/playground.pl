#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";
use Astro::Nova;
use Data::Dumper 'Dumper';
$Data::Dumper::Indent = 0;

$ENV{TZ}="UTC";

# my location
my $observer = Astro::Nova::LnLatPosn->new();
$observer->set_lat(70);
$observer->set_lng(0);
$observer->set_altitude(5000);

# unix time
$ut = Time::Local::timegm(0,0,12,14,5-1,2012);
$jd = Astro::Nova::get_julian_from_timet($ut);

# rst
$rst = Astro::Nova::get_solar_rst($jd, $observer);
debug(Astro::Nova::get_timet_from_julian($rst->get_rise()));
debug(Astro::Nova::get_timet_from_julian($rst->get_set()));

die "TESTING";

$dms = Astro::Nova::DMS->new(0,25,03,22);
debug($dms->get_degrees());
debug($dms->get_minutes());
debug(dump_var($dms));

die "TESTING";

$observer->set_lat(Astro::Nova::DMS->from_string("49 degrees")->to_degrees);
$observer->set_lng(Astro::Nova::DMS->from_string("8 E"));

# debug("NOW",dump_var($now));
debug(dump_var($observer));

=item docs

(int $status, Astro::Nova::RstTime $rst) =
  get_object_rst(double JD, Astro::Nova::LnLatPosn observer, Astro::Nova::EquPosn object)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_rst_horizon(double JD, Astro::Nova::LnLatPosn observer,
                         Astro::Nova::EquPosn object, double horizon)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_next_rst(double JD, Astro::Nova::LnLatPosn observer, Astro::Nova::EquPosn object)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_next_rst_horizon(double JD, Astro::Nova::LnLatPosn observer,
                              Astro::Nova::EquPosn object, double horizon)

=cut
