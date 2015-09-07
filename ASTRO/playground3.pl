#!/bin/perl

require "/usr/local/lib/bclib.pl";

# Julian Dates, the adventure continues

# lets add multiple 400 year periods (400 years = 146097 days)

$jd = -3089124.5;

$jd= ($jd-2451543.5)%146097+2451543.5;

my($date) = Astro::Nova::get_date($jd);
my(@date) = ($date->get_years(), $date->get_months(),
	     $date->get_days(), $date->get_hours(),
	     $date->get_minutes(), $date->get_seconds());
debug("$jd ->",join(" ",@date));

die "TESTING";

for $y (-13200..-4000) {
  my($jdmar1) = int(($y+13199)*365.2425)-3099351.5;
#  if ($y%4==3||$y%4==0) {$jdmar1++;}

#  my($jdmar1) = int(($y+4713)*365.25)+120.5;
#  if ($y%4==3) {$jdmar1++;}
  print "$y $jdmar1\n";
}

=item comment

Above breaks down:



# use Date::Convert;
# $date=new Date::Convert::Absolute(10000.);
# convert Date::Convert::Julian $date;
# print $date->date_string, "\n";

# use Date::JD qw(jd_to_mjd mjd_to_cjdnf cjdn_to_rd);

# $mjd = jd_to_mjd($jd);
# ($cjdn, $cjdf) = mjd_to_cjdnf($mjd, $tz);
# $rd = cjdn_to_rd($cjdn, $cjdf);

# debug(strftime("%Y-%m-%d",gmtime(-999999999999)));
