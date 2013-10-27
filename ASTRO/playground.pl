#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";
use Astro::Nova;
use Data::Dumper 'Dumper';
$Data::Dumper::Indent = 0;

#$ENV{TZ}="UTC";

# %hash = suninfo(-106-35/60,75+0*35.1, str2time("Nov 15"));
%hash = sunmooninfo(-106-35/60,35.1);

for $i (keys %hash) {
  for $j (keys %{$hash{$i}}) {
    print strftime("$i$j: %x %I:%M %p\n",localtime($hash{$i}{$j}));
  }
}

=item sunmooninfo($lon,$lat,$time=now)

Return hash of info about the sun/moon at $lon, $lat at time $time

=cut

sub sunmooninfo {
  my($lon,$lat,$time) = @_;
  my(%info); # return hash
  unless ($time) {$time=time();}

  # construct observer
  my($observer) = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);
  # jd2unix() would also do this
  my($jd) = Astro::Nova::get_julian_from_timet($time);

  my($stat,$rst) = Astro::Nova::get_solar_rst_horizon($jd, $observer, -5/6.);
  debug("STAT1: $stat");

  $info{sun}{rise} = Astro::Nova::get_timet_from_julian($rst->get_rise());
  $info{sun}{set} = Astro::Nova::get_timet_from_julian($rst->get_set());
  $info{sun}{transit} = Astro::Nova::get_timet_from_julian($rst->get_transit());

  ($stat,$rst) = Astro::Nova::get_solar_rst_horizon($jd, $observer, -6.);
  debug("STAT2: $stat");
  $info{sun}{dawn} = Astro::Nova::get_timet_from_julian($rst->get_rise());
  $info{sun}{dusk} = Astro::Nova::get_timet_from_julian($rst->get_set());

  ($stat,$rst) = Astro::Nova::get_lunar_rst($jd, $observer);
  debug("STAT3: $stat");
  $info{moon}{rise} = Astro::Nova::get_timet_from_julian($rst->get_rise());
  $info{moon}{set} = Astro::Nova::get_timet_from_julian($rst->get_set());
  $info{moon}{transit} = Astro::Nova::get_timet_from_julian($rst->get_transit());

  return %info;
}

die "TESTING";

my $observer = Astro::Nova::LnLatPosn->new();
$observer->set_lat(80);
$observer->set_lng(0);

$jd = Astro::Nova::get_julian_from_timet(1361360700+60);

$ans = Astro::Nova::get_solar_equ_coords($jd);
$ans2 = Astro::Nova::get_hrz_from_equ($ans, $observer, $jd);

debug(%Astro::Nova::HrzPosn::);

# debug(methods($ans2));

debug($ans2,$ans2->get_alt(), $ans2->get_az());


# rst
# $rst = Astro::Nova::get_solar_rst($jd, $observer);
# debug(Astro::Nova::get_timet_from_julian($rst->get_rise()));
# debug(Astro::Nova::get_timet_from_julian($rst->get_set()));

die "TESTING";

# below is http://stackoverflow.com/questions/16293146

# my location
my $observer = Astro::Nova::LnLatPosn->new();
$ut = Time::Local::timegm(0,0,0,1,1-1,2013);
$jd = Astro::Nova::get_julian_from_timet($ut);
$rst = Astro::Nova::get_solar_equ_coords($jd);
debug($rst->get_ra(), $rst->get_dec());

die "TESTING";

$observer->set_lat(70);
$observer->set_lng(0);
$observer->set_altitude(5000);

# unix time
$ut = Time::Local::timegm(0,0,12,14,5-1,2012);
$jd = Astro::Nova::get_julian_from_timet($ut);

# rst
$rst = Astro::Nova::get_solar_rst($jd, $observer);
debug(Astro::Nova::get_timet_from_julian($rst->get_rise()));
debug(Astro::Nova::get_timet_from_julian($rst->get_set()));

die "TESTING";

$dms = Astro::Nova::DMS->new(0,25,03,22);
debug($dms->get_degrees());
debug($dms->get_minutes());
debug(dump_var($dms));

die "TESTING";

$observer->set_lat(Astro::Nova::DMS->from_string("49 degrees")->to_degrees);
$observer->set_lng(Astro::Nova::DMS->from_string("8 E"));

# debug("NOW",dump_var($now));
debug(dump_var($observer));

=item docs

(int $status, Astro::Nova::RstTime $rst) =
  get_object_rst(double JD, Astro::Nova::LnLatPosn observer, Astro::Nova::EquPosn object)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_rst_horizon(double JD, Astro::Nova::LnLatPosn observer,
                         Astro::Nova::EquPosn object, double horizon)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_next_rst(double JD, Astro::Nova::LnLatPosn observer, Astro::Nova::EquPosn object)
  (int $status, Astro::Nova::RstTime $rst) =
  get_object_next_rst_horizon(double JD, Astro::Nova::LnLatPosn observer,
                              Astro::Nova::EquPosn object, double horizon)

=cut
