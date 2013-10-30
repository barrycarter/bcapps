#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";
use Data::Dumper 'Dumper';
$Data::Dumper::Indent = 0;

# debug(np_rise_set(0,80,time(),"moon","rise",-1));

$lon = -106-39/60.;
$lat = 89.5;
$time = time()+86400*15;

# info I actually want

my(%sunmooninfo) = sunmooninfo($lon,$lat,$time);

for $i ("sun","moon","civ") {
  if ($sunmooninfo{$i}{alt} > 0) {
    # if sun/moon up give me previous rise + next set
    my($lr) = np_rise_set($lon,$lat,$time,$i,"rise",-1);
    my($ns) = np_rise_set($lon,$lat,$time,$i,"set",1);
    print strftime("$i up\nRise: %c\n", localtime($lr));
    print strftime("Set: %c\n\n", localtime($ns));
  } else {
    # otherwise, last set and next rise
    my($ls) = np_rise_set($lon,$lat,$time,$i,"set",-1);
    my($nr) = np_rise_set($lon,$lat,$time,$i,"rise",1);
    print strftime("$i down\nSet: %c\n", localtime($ls));
    print strftime("Rise: %c\n\n", localtime($nr));
  }
}

debug(unfold(%sunmooninfo));

die "TESTING";

for $i (-1,1) {
  for $j ("moon", "sun", "civ", "naut", "astro") {
    for $k ("rise","set") {
      print strftime("$j$k ($i): %c\n",localtime(np_rise_set($lon,$lat,time(),$j,$k,$i)));
    }
  }
}

die "TESTING";

#$ENV{TZ}="UTC";

# %hash = suninfo(-106-35/60,75+0*35.1, str2time("Nov 15"));
# %hash = sunmooninfo(-106-35/60,35.1,time()-12*3600);

# high latitude sun/moon info
%hash = testing(0,80,time());

for $i (keys %hash) {
  for $j (keys %{$hash{$i}}) {
    print strftime("$i$j ($hash{$i}{$j}): %x %I:%M:%S %p\n",localtime($hash{$i}{$j}));
  }
}

# if sun is up, previous rise and next set; if down, previous set and next rise (wrapper around sunmooninfo)

sub testing {
  my($lon, $lat, $time) = @_;

  my(%info) = sunmooninfo($lon,$lat,$time);
  # variable for loop
  my($timel) = $time;

  # if sun is down, seek to next rise (which may already be in %info)
  if ($info{sun}{alt} < 0) {
    # negative results = no sun rise
    while ($info{sun}{rise} < 0 || $info{sun}{rise} < $time) {
      $timel += 12*3600; # TODO: could I get away with 24 here?
      debug("TIMEL: $timel");
      %info = sunmooninfo($lon,$lat,$timel);
    }
  }

  debug(unfold(%info));
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
