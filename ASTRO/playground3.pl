#!/bin/perl

require "/usr/local/lib/bclib.pl";

# Julian Dates, the adventure continues

for $y (-8000..-4000) {
  my($jdmar1) = int(($y+4713)*365.25)+120.5;
  if ($y%4==3) {$jdmar1++;}
  print "$y $jdmar1\n";
}

# use Date::Convert;
# $date=new Date::Convert::Absolute(10000.);
# convert Date::Convert::Julian $date;
# print $date->date_string, "\n";

# use Date::JD qw(jd_to_mjd mjd_to_cjdnf cjdn_to_rd);

# $mjd = jd_to_mjd($jd);
# ($cjdn, $cjdf) = mjd_to_cjdnf($mjd, $tz);
# $rd = cjdn_to_rd($cjdn, $cjdf);

# debug(strftime("%Y-%m-%d",gmtime(-999999999999)));
