#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";
use Data::Dumper 'Dumper';
$Data::Dumper::Indent = 0;

$foo = sub {return 5;};
debug("FOO: $foo");







die "TESTING";

# debug(np_rise_set(0,80,time(),"moon","rise",-1));

$lon = -106-39/60.;
$lat = 35.1;

for $i (-1,1) {
  for $j ("moon", "sun", "civ", "naut", "astro") {
    for $k ("rise","set") {
      print strftime("$j$k($i): %c\n",localtime(np_rise_set($lon,$lat,time(),$j,$k,$i)));
    }
  }
}

# debug(np_rise_set(-106.5,35.1,time(),"moon","rise",-1));

=item np_rise_set($lon, $lat, $time=now, $obj="sun|moon", $which="rise|set", $dir="-1|1")

Gives the next/previous rise/set time of the sun/moon for an observer
at $lon, $lat at time $time

TODO: add various twilights

=cut

sub np_rise_set {
  my($lon, $lat, $time, $obj, $which, $dir) = @_;
  unless ($time) {$time = time();}
  my($observer,$jd,$stat,$data,$eventtime,$tempfunc);

  # for speed reasons, can not use sunmooninfo()
  # TODO: allow sunmooninfo to provide one or the other if desired
  $observer = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);
  $jd = get_julian_from_timet($time);

  # the various twilights
  if ($obj=~/astro/i) {
    $tempfunc = sub {return get_solar_rst_horizon(@_,-18);}
  } elsif ($obj=~/naut/i) {
    sub tempfunc {return get_solar_rst_horizon(@_,-12);}
  } elsif ($obj=~/civ/i) {
    sub tempfunc {return get_solar_rst_horizon(@_,-6);}
  } elsif ($obj=~/sun/i) {
    sub tempfunc {return get_solar_rst_horizon(@_,-5/6);}
  } elsif ($obj=~/moon/i) {
    sub tempfunc {return get_lunar_rst(@_);}
  } else {
    warn "$obj not understood";
    return;
  }

  for (my($i)=$jd; $i<=2465789; $i+=$dir/2.) {
    debug("I: $i, $observer->as_ascii()");
    ($stat, $data) = &($tempfunc)($i, $observer);
    $eventtime = eval("\$data->get_$which()");
    # eventtime must meet sorting criteria wo being insanely high/low
    if ($dir==+1 && $eventtime>=$jd && $eventtime <= 2465789) {last;}
    if ($dir==-1 && $eventtime<=$jd && $eventtime >= 2440587) {last;}
    debug("ET: $eventtime");
  }

  return get_timet_from_julian($eventtime);
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
