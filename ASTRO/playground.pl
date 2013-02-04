#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";
use Astro::Nova;
use Data::Dumper 'Dumper';
$Data::Dumper::Indent = 0;

# my location
my $observer = Astro::Nova::LnLatPosn->new();
$observer->set_lat(35.1);
$observer->set_lng(-106.5);

# julian day
$jd = Astro::Nova::get_julian_from_sys();
debug("NOW: $jd");
# below is dec 22nd
$jd = Astro::Nova::get_julian_from_timet(1356159600);
debug("THEN: $jd");

# rst
$rst = Astro::Nova::get_solar_rst($jd, $observer);
debug(Astro::Nova::get_timet_from_julian($rst->get_rise()));
debug($rst);


# solar geocentric(?) coords
# $c1 = Astro::Nova::get_solar_geom_coords($jd);

# ra/dec
# $radec = Astro::Nova::get_solar_equ_coords($jd);

# debug("RADEC: ",$radec->get_ra(), $radec->get_dec());

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
