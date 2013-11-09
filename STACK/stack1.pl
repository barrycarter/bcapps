#!/usr/bin/perl

use Astro::Nova qw(get_solar_equ_coords get_lunar_equ_coords get_hrz_from_equ
		   get_solar_rst_horizon get_timet_from_julian
		   get_julian_from_timet get_lunar_rst get_lunar_phase);

# julian
$day = 2456535;
$observer = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>89.5);

for ($i=$day; $i<$day+180; $i++) {
  print "DAY: $i\n";
  ($status,$rst) = get_lunar_rst($i, $observer);
  print "STATUS: $status\n";

  $rise = $rst->get_rise();
  # ignore ridiculous values
  if ($rise > 1e+10 || $rise < 1e-10) {
    print "RISE: ERR\n";
  } else {
    print "RISE: $rise\n";
  }

#  $trans = $rst->get_transit();

  $set = $rst->get_set();
  # ignore ridiculous values
  if ($set > 1e+10 || $set < 1e-10) {
    print "SET: ERR\n";
  } else {
    print "SET: $set\n";
  }
}


