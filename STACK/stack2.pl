#!/usr/bin/perl

use Astro::Nova qw(get_solar_equ_coords get_lunar_equ_coords get_hrz_from_equ
		   get_solar_rst_horizon get_timet_from_julian
		   get_julian_from_timet get_lunar_rst get_lunar_phase);

$observer = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>89.5);

for $i (2456623..2456624) {
  print "DAY: $i\n";
  ($status,$rst) = get_lunar_rst($i, $observer);
  print "STATUS: $status\n";

  $rst->get_transit();

  $rise = $rst->get_rise();
  print "RISE: $rise\n";
  $set = $rst->get_set();
  print "SET: $set\n\n";
}



