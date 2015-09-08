#!/bin/perl

require "/usr/local/lib/bclib.pl";


# Julian Dates, the adventure continues

while (<>) {
  chomp;

  # just testing, format is year jd
  my($sec,$jd,$date,$time) = split(/\s+/,$_);

  debug("$date ($jd) ->".jd2proleptic_julian_ymdhms($jd));
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

=item jd2proleptic_julian_ymdhms($jd)

Given a Julian date, returns the proleptic Julian year/month/day etc.

Proleptic Julian = assumes the Julian calendar (1 leap year every 4
years w/ no variance) is always used

=cut

sub jd2proleptic_julian_ymdhms {
  my($jd) = @_;

  # The Julian calendar repeats every 4*365+1 = 1461 days
  # using 2000-2003 as "reference date"
  # [2000 1 1 = JD 2451544.500000 = Unix 946684800]
  # how many "chunks" of 1461 days ago is/was this?
  # 13 to compensate for Gregorian reformation
  my($yrs) = ($jd-2451544.500000-13.);
  # how many days into this chunk?
  my($chunks,$days) = (floor($yrs/1461),fmodp($yrs,1461));
  debug("CD: $yrs/$chunks/$days");
  my(@gm) = gmtime(946684800+$days*86400);
#  debug(946684800+$days*86400,"becomes",@gm);
  debug(strftime("PRE: %Y-%m-%d %H:%M:%S",@gm));
  # adjust the year (gmtime returns years-1900, thus the adjustment below)
  debug("OLD: $gm[5]");
  $gm[5] += 1900+4*$chunks;
  debug("NEW: $gm[5]");
  debug("$gm[5]-$gm[4]-$gm[3] $gm[2]:$gm[1]:$gm[0]");
}


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

