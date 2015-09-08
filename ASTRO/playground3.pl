#!/bin/perl

require "/usr/local/lib/bclib.pl";


# Julian Dates, the adventure continues

while (<>) {
  chomp;

  # just testing, format is year jd
  my($sec,$jd,$date,$time) = split(/\s+/,$_);
  my(@l) = jd2proleptic_julian_ymdhms($jd);
  debug("JULIAN: $date ($jd) ->".join(" ",@l));
  my(@l) = jd2proleptic_gregorian_ymdhms($jd);
  debug("GREGOR: $date ($jd) ->".join(" ",@l));
  my(@l) = jd2mixed_ymdhms($jd);
  debug("MIXED: $date ($jd) ->".join(" ",@l));
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

See jd2mixed_ymdhms() for caveats

=cut

sub jd2proleptic_julian_ymdhms {
  my($jd) = @_;

  # The Julian calendar repeats every 4*365+1 = 1461 days
  # using 2000-2003 as "reference date"
  # [2000 1 1 = JD 2451544.500000 = Unix 946684800, so 2451543.500000 = day 0]
  # how many "chunks" of 1461 days ago is/was this?
  # 14 to compensate for Gregorian reformation
  my($yrs) = ($jd-2451543.500000-14.);
  # how many days into this chunk?
  my($chunks,$days) = (floor($yrs/1461),fmodp($yrs,1461));
  my(@gm) = gmtime(946684800+$days*86400);
  # adjust the year (gmtime returns years-1900, thus the adjustment below)
  $gm[5] += 1900+4*$chunks;
  # gmtime returns month-1, so...
  $gm[4]++;
  return(reverse(@gm[0..5]));
}

=item jd2proleptic_gregorian_ymdhms($jd)

Given a Julian date, returns the proleptic Gregorian year/month/day etc.

Proleptic Gregorian = assumes the Gregorian calendar (1 leap year every 4
years except every 100 years except every 400 years) is always used

See jd2mixed_ymdhms() for caveats

=cut

sub jd2proleptic_gregorian_ymdhms {

  my($jd) = @_;

  # "reduce" this date to 2000-2399, by adding/subtracting 400 year periods
  # JD 2451543.5 = 1999-12-31 00:00:00, day 0 of year 2000
  my($yrs) =$jd-2451543.500000;

  # The Gregorian calendar repeats every 400 years = 146097 days
  my($chunks,$days) = (floor($yrs/146097),fmodp($yrs,146097));
  # compute for newjd (add to days to bring back into 2000-2399 era)
  my($date) = Astro::Nova::get_date($days+2451543.5);
  my(@date) = ($date->get_years(), $date->get_months(),
	     $date->get_days(), $date->get_hours(), $date->get_minutes,
	      $date->get_seconds);
  # adjust
  $date[0] += 400*$chunks;
  return @date;
}

=item jd2mixed_ymdhms($jd)

Returns either the Gregorian year/month/date/etc or the Julian one,
depending on whether is it before or after the Reformation:

TODO: allow user to choose Reformation date, one below is per NASA:

http://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/req/time.html#Calendars

Julian 1582 Oct 5 = Gregorian 1582 Oct 15 = JD 2299160.500000

Caveats: following the astronomical convention that 1BC is year 0, 2BC
is year -1, and so on, since Im mostly doing this for Stellarium dates:

http://www.stellarium.org/wiki/index.php/FAQ#.22There_is_no_year_0.22.2C_or\
_.22BC_dates_are_a_year_out.22

=cut

sub jd2mixed_ymdhms {
  my($jd) = @_;

  if ($jd<2299160.5) {return jd2proleptic_julian_ymdhms($jd);}
  return jd2proleptic_gregorian_ymdhms($jd);
}
