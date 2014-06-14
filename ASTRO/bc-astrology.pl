#!/bin/perl

# exploring the kind of astrology they do at astro.com for purely
# mathematical reasons

require "/usr/local/lib/bclib.pl";
use Astro::Nova;

my(@consts) = split(/\//, "Aries/Taurus/Gemini/Cancer/Leo/Virgo/Libra/Scorpio/Saggitarius/Capricornus/Aquarius/Pisces");

# http://www.astro.com/astrology/in_signs_e.htm shows ecliptic longitude

# derivative of ecliptic longitude also needed (signum only)

$jd = get_julian_from_timet(str2time("2014-01-01 00:00:00 UTC"));
$jd = 2456658.500000;
debug("JD: $jd");

for $i ((split(/\|/, "solar|lunar|mercury|venus|mars|jupiter|saturn|uranus|neptune|pluto"))) {

  # get ecliptic longitude
  my($equ) = eval("Astro::Nova::get_${i}_equ_coords($jd)");
  my($ra,$dec) = ($equ->get_ra(), $equ->get_dec());
  my($res) = get_ecl_from_equ($equ, $jd)->get_lng();
  my($sign, $d, $m, $s) = dec2deg($res);
  my($const, $into) = (floor($res/30), fmod($res,30));
  debug("$i: $consts[$const] $into, $ra, $dec");
}

die "TESTING";

$obj = get_ecl_from_equ(get_mars_equ_coords($jd), $jd);
debug($obj->get_lng());




