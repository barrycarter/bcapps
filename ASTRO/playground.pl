#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";
use Data::Dumper 'Dumper';
$Data::Dumper::Indent = 0;

$observer = Astro::Nova::LnLatPosn->new("lng"=>-106,"lat"=>35);
# debug($observer->get_lng());

debug(get_body_rst_horizon2(2456614, $observer, \&get_lunar_equ_coords));

=item get_body_rst_horizon2($jd, $observer, $get_body_equ_coords, $horizon)

For Julian day $jd and observer $observer, give the rise/set/transit
times of body whose coordinates are given by the function
$get_body_equ_coords; rise and set are computed relative to $horizon

NOTE: $jd should be an integer
TODO: what is get_dynamical_time_diff() and why do I need it?
TODO: handle multiple rise/sets in a given day

=cut

sub get_body_rst_horizon2 {
  my($jd, $observer, $get_body_equ_coords, $horizon) = @_;

  # body's ra/dec at $jd+.5
  my($pos) = &$get_body_equ_coords($jd+.5);

  # local siderial time at midday JD (midnight GMT, 5pm MST, 6pm MDT)
  my($lst) = fmodp(get_apparent_sidereal_time($jd+.5)+$observer->get_lng()/15,24);
  # approximate transit time of body (as fraction of day)
  my($att) = fmodp(0.5+($pos->get_ra()/15-$lst)/24,1);

  # function giving altitude of body for $observer at given time
  my($f) = sub {get_hrz_from_equ(&$get_body_equ_coords($_[0]), $observer, $_[0])->get_alt()};
  
  for ($i=$jd; $i<$jd+1; $i+=0.01) {
    debug($i,&$f($i));
  }

#  debug("LST: $lst, MP: ",$pos->get_ra()/15);
  debug("ATT: $att");


}

die "TESTING";

$observer = Astro::Nova::LnLatPosn->new("lng"=>-60,"lat"=>70);

# for ($i=2456327.5; $i<2456329; $i+=.01) {
for ($i=2456329; $i<=2456331; $i++) {
  print "DAY: $i\n";
  ($status,$rst) = get_lunar_rst($i, $observer);
  print "STATUS: $status\n";

  $rst->get_transit();

  $rise = $rst->get_rise();
  print "RISE: $rise\n";
  $set = $rst->get_set();
  print "SET: $set\n\n";
}

die "TESTING";

# lunar elevation at 89.5,0 at given time
sub fx {
  my($t) = @_;
  my($pos) = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>89.5);
  my($altaz) = get_hrz_from_equ(get_lunar_equ_coords($t), $pos, $t);
  return $altaz->get_alt()-0.125;
}

debug(fx(2456623.83105469));

my($res) = findroot(\&fx, 2456623, 2456624, .001);
my($res2) = findmin(\&fx, 2456623, 2456624, .001);

debug("RES: $res, RES: $res2");

debug(fx($res2));

die "TESTING";

debug(mooninfo(time()));

die "TESTING";

$t = 1384063127.11639;
print join("\n", phasehunt($t)),"\n";
@arr = phase($t);
print "$arr[2]\n";

die "TESTING";

for $i (0..140) {
  $t = 1383483033+86400*$i/10;
  %sm = sunmooninfo(-106,35, $t);
  print "$i $sm{moon}{phase}\n";
  push(@xs, $i);
  push(@ys, $sm{moon}{phase});
#  print $sm{moon}{phase}/$i,"\n";
}

debug(unfold(linear_regression(\@xs,\@ys)));

die "TESTING";

$lon = 0.;
$lat = 89.5;
$time = 1383918337;
# julian
$day = 2456605-60;
$observer = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);

for ($i=$day; $i<$day+180; $i++) {
  $rst = get_lunar_rst($i, $observer);
  debug("RST: $rst");
  debug("TIMES($i)", $rst->get_rise(), $rst->get_transit(), $rst->get_set());
}

die "TESTING";

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

# why does libastro fail sometimes?
# below chosen "randomly"
$jd = 2456605;
$lon = -106;
$lat = 35;
$observer = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);
debug("OBS:", $observer->as_ascii());
$sunpos = get_solar_equ_coords($jd);
$moonpos = get_lunar_equ_coords($jd);
$rst = get_lunar_rst($jd,$observer);
debug("RST",$rst->get_set());


die "TESTING";

# hideous way of seeing moon is waxing or waning

# linear regress date of new/etc moons ("good enough" for lunar phase calc?)

@y = split(/\n/, read_file("/tmp/phases.txt"));
@x = (0..$#y);

debug(linear_regression(\@x,\@y));

# 7.3823125330 between phases or 637831.802853671s, lc 1388570812.87346
# full moons only: 1389850790.98776 2551297.36530609

for $i (@y) {
#  my($guess) = 1388570812.87346+$n*637831.802853671;
  my($guess) = 1389850790.98776+$n*2551297.36530609;
  print $i-$guess;
  $n++;
  print "\n";
}

die "TESTING";

# debug(np_rise_set(0,80,time(),"moon","rise",-1));
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
