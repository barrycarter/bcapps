#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";
use Astro::Nova;
use Data::Dumper 'Dumper';
$Data::Dumper::Indent = 0;

$now = Astro::Nova::get_julian_from_sys();

$test = new Astro::Nova::LnLatPosn();
$test::lat = 35;


# debug("NOW",dump_var($now));
debug(dump_var($test));

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
