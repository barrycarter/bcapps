#!/bin/perl

require "/usr/local/lib/bclib.pl";


# Julian Dates, the adventure continues

while (<>) {
  chomp;

  # just testing, format is year jd
  my($year,$jd) = split(/\s+/,$_);
  debug("$year ($jd) ->".join(" ",jd2ymdhms_test($jd)));
}

die "TESTING";

for $y (-13200..-4000) {
  my($jdmar1) = int(($y+13199)*365.2425)-3099351.5;
#  if ($y%4==3||$y%4==0) {$jdmar1++;}

#  my($jdmar1) = int(($y+4713)*365.25)+120.5;
#  if ($y%4==3) {$jdmar1++;}
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

sub jd2ymdhms_test {

  my($jd) = @_;

  # "reduce" this date to 2000-2399, by adding/subtracting 400 year periods
  # JD 2451543.5 = 1999-12-31 00:00:00, day 0 of year 2000

  # how many 400 year periods we add/subtract
  my($div) = floor(($jd-2451543.5)/146097);

  # how many days are leftover
  my($newjd) = ($jd-2451543.5)%146097+2451543.5;

  # compute for newjd
  my($date) = Astro::Nova::get_date($newjd);
  my(@date) = ($date->get_years(), $date->get_months(),
	     $date->get_days());

  # Astro::Nova::get_date doesn't compute hms
  my($hms) = fmod(24*($jd-floor($jd))+12,24);

  # TODO: there are much better ways to do this
  push(@date,floor($hms));
  $hms-=floor($hms);
  $hms*=60;
  push(@date,floor($hms));
  $hms-=floor($hms);
  $hms*=60;
  push(@date,$hms);

  # fix the year, otherwise all good
  # following astronomical convention that 1 BCE = 0, 2 BCE = -1, etc:
  # http://www.stellarium.org/wiki/index.php/FAQ#.22There_is_no_year_0.22.2C_or_.22BC_dates_are_a_year_out.22

  $date[0] += 400*$div;

  return @date;
}

