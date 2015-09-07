#!/bin/perl

require "/usr/local/lib/bclib.pl";


=item jd2ymdhms($jd)

Given a Julian date, return the year, month, date, hour, minute, and
second, in the same way that
http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/cspice/etcal_c.html
would

=cut

sub jd2ymdhms {
  my($jd) = @_;

  # "reduce" this date to 2000-2399, by adding/subtracting 400 year periods
  # JD 2451543.5 = 1999-12-31 00:00:00, day 0 of year 2000

  # how many 400 year periods we add/subtract
  my($div) = int(($jd-2451543.5)/146097);

  # how many days are leftover
  my($newjd) = ($jd-2451543.5)%146097+2451543.5;

  # compute for newjd
  my($date) = Astro::Nova::get_date($newjd);
  my(@date) = ($date->get_years(), $date->get_months(),
	     $date->get_days(), $date->get_hours(),
	     $date->get_minutes(), $date->get_seconds());

  # fix the year, otherwise all good
  $date[0] += 400*($div-1)-1;

  return @date;
}


# Julian Dates, the adventure continues

while (<>) {
  chomp;

  # just testing, format is year jd
  my($year,$jd) = split(/\s+/,$_);
  debug("$year ($jd) ->".join(" ",jd2ymdhms($jd)));
}

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
