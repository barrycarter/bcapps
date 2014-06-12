#!/bin/perl

# exploring the kind of astrology they do at astro.com for purely
# mathematical reasons

require "/usr/local/lib/bclib.pl";
use Astro::Nova;

# http://www.astro.com/astrology/in_signs_e.htm shows ecliptic longitude

# derivative of ecliptic longitude also needed (signum only)

$jd = get_julian_from_timet(time());

for $i ((split(/\|/, "solar|lunar|mercury|venus|mars|jupiter|saturn|uranus|neptune|pluto"))) {
  my($f) = "Astro::Nova::get_${i}_equ_coords($jd)";
  my($res) = eval($f);
  debug("RES: $res");
  my($obj) = get_ecl_from_equ($res, $jd);
#  debug("OBJ: $obj");
  debug("RES: ",$obj->get_lng());
#  debug("F: $f");
#  debug("I: $i");
}

die "TESTING";

$obj = get_ecl_from_equ(get_mars_equ_coords($jd), $jd);
debug($obj->get_lng());




