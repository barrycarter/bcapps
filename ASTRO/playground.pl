#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";

# on an ortho map, what goes in the .2,.3 to .3,.4 square (reverse
# quadrangling), in terms of a mercator map

# ortho limits: +-6378137 for x coord, same for y coord

# .1 = 637813.7, .2 = 1275627.4, .3 = 1913441.1, .4 = 2551254.8, .5 = 3189068.5

# cs2cs -e 'ERR ERR' +proj=ortho +to +proj=merc
# .2,.3 to 1347216.35 1961346.56 (NW)
# .3,.4 to 2126937.58 2685005.75 (SE)
# .2,.4 to 1403113.46 2685005.75 (SW)
# .3,.3 to 2040458.85 1961346.56 (NE)

# merc limits: +-20037508.34 in x direction, unlimited in y direction

# merc x range: 1347216.35 to 2126937.58
# merc y range: 1961346.56 to 2685005.75

# scaled x: .0672347243 to .1061478075
# scaled y: .0978837551 to .1339989835

# xwidth (scaled): .0389130832
# ywidth (scaled): .0361152284

# so about 1/32 width or 1/2^5 so level 5 slippy tile?

# roughly x tile 2
# roughly y tile 3

# better (Spain-ish): .4 - .5 in the x range and .1 - .2 in y range

# unscaled x: 2638741.07 to 3415783.48
# unscaled y: 635682.73 to 1284515.71

# scaled x: .1316900796 to .1704694726
# scaled y: .0317246395 to .0641055608

# right about level 5 tiles, x starting at 4.21ish, y at 1ish

# 2,1,1... children are 3,3,3 then 4,7,6 then 5,15,12





die "TESTING";

debug(num2base(4416951459393930,256));

die "TESTING";

# chebyshev

open(A,"bzcat /home/barrycarter/BCGIT/ASTRO/ascp1950.430.bz2|");

while (<A>) {
  # strip leading spaces and split into fields
  s/^\s+//isg;
  @fields = split(/\s+/, $_);

  # if this line has two integers, it's a section boundary
  # which means next line will be date spec
  if ($#fields==1 && $fields[0]=~/^\d+$/ && $fields[1]=~/^\d+$/) {
    $bound = 1;

    # TESTING ONLY: if we hit a boundary and have @coeffs, drop out of loop
    if ($#coeffs>2) {last;}

    next;
  }

  # convert from Fortran to Perl
  for $i (@fields) {$i=~s/^(.*?)D(.*)$/$1*10**$2/e;}

  # if we just hit a boundary, get date spec
  if ($bound) {
    ($sdate, $edate) = @fields;
    # indicate we are no longer at a boundary
    $bound = 0;
    # and store the third item in this row which is the first coefficient
    @coeffs = $fields[2];
    next;
  }

  # debug("IGNORING: $sdate-$edate");
  # this is 2011-01-01 00:54:00 GMT, close to earliest time I have data for
  if ($sdate <= 2455562.5375000000) {next;}

#  debug("THUNK: $_","FIELDS",@fields);
  push(@coeffs, @fields);
}

debug("$sdate-$edate");

# the first chunk is: 2455568.5-2455600.5

debug($#coeffs);

die "TESTING";

# the first 14 coeffs are the x coordinate of mercury for first 8 days
for $i (0..13) {
  push(@sum, sprintf("%f*ChebyshevT[$i,x]",$coeffs[$i]));
}

# the coeffs from 14-27 and 28-41 and y and z mercury coords first 8 days
# below are coeffs for x position mercury next 8 days
for $i (42..42+13) {
  $j = $i-42;
  push(@sum2, sprintf("%f*ChebyshevT[$j,x]",$coeffs[$i]));
}

print join("+\n", @sum),"\n";
print "\n\n";
print join("+\n", @sum2),"\n";

die "TESTING";

for $i (@coeffs) {
  debug(sprintf("%f",$i));
}

die "TESTING";

my($observer) = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>35);


for $i (0..1439) {
  $t = 1386720000+713*60+60*$i;
  $jd = get_julian_from_timet($t);
  $az=get_hrz_from_equ(get_solar_equ_coords($jd), $observer, $jd)->get_az();
#  $az = $az - $i/4;
  print "$az\n";
}

die "TESTING";

for $i (1..100) {
  sleep(1);
  $randlat = rand(180)-90;
  $randlon = rand(360)-180;
  for $j ("s","m") {
    get_usno_calendar(2014, $randlon, $randlat, $j);
  }
}


die "TESTING";

$observer = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>70);
# $observer = Astro::Nova::LnLatPosn->new("lng"=>-106.5,"lat"=>35);
# $observer = Astro::Nova::LnLatPosn->new("lng"=>0,"lat"=>80);
# get_body_rst_horizon2(2456620, $observer, \&get_lunar_equ_coords, 0.125);

$rep = get_body_rst_horizon3(2456450.500000, $observer, \&get_lunar_equ_coords, 0.125);
# $rep = get_body_rst_horizon3(2456620-33.5, $observer, \&get_solar_equ_coords, -5/6.);

debug("REP!");
debug($rep->get_rise());
debug($rep->get_transit());
debug($rep->get_set());

die "TSETING";

=item get_body_minmax_alt($jd, $observer, $get_body_equ_coords, $minmax=-1|1)

Determine time body reaches minimum/maximum altitude for $observer
between $jd and $jd+1, where bodys equitorial coordinates are given
by $get_body_equ_coords, a function.

Uses first derivative for efficiency, but allows for possibility that
min/max altitude is reached at a boundary condition.

=cut

sub get_body_minmax_alt {
  my($jd, $observer, $get_body_equ_coords, $minmax) = @_;

  # body's ra/dec at $jd+.5
  my($pos) = &$get_body_equ_coords($jd+.5);
  # precision
  my($precision) = 1/86400;

  # local siderial time at midday JD (midnight GMT, 5pm MST, 6pm MDT)
  my($lst) = fmodp(get_apparent_sidereal_time($jd+.5)+$observer->get_lng()/15,24);
  # approximate transit/zenith or nadir time of body (as fraction of day)
  my($att) = fmodp(1/4+$minmax/4+($pos->get_ra()/15-$lst)/24,1);

  # the psuedo first derivative of the body's elevation
  my($delta) = 1/86400.;
  my($f) = sub {(get_hrz_from_equ(&$get_body_equ_coords($_[0]+$delta), $observer, $_[0]+$delta)->get_alt() - get_hrz_from_equ(&$get_body_equ_coords($_[0]-$delta), $observer, $_[0]-$delta)->get_alt())/$delta/2};

  # TODO: can D[object elevation,t] be non-0 for 12h+ (retrograde?)
  # the max altitude occurs w/in 6 hours of approx transit time
  my($ans) = findroot2($f, $jd+$att-1/4, $jd+$att+1/4, $precision);

  # $ans may've slipped into next/previous day; if so, look at next/prev day
  if ($ans < $jd) {
    $ans=findroot2($f,$jd+$att+3/4,$jd+$att+5/4,0,"delta=$precision");
  } elsif ($ans > $jd+1) {
    $ans=findroot2($f,$jd+$att-5/4,$jd+$att-3/4,0,"delta=$precision");
  }

  # altitudes at various times (exclude $ans if its STILL out of range)
  my(%alts);

  for $i ($jd, $ans, $jd+1) {
    if ($i>=$jd && $i<=$jd+1) {
      debug("I: $i");
      $alts{$i} = 
	get_hrz_from_equ(&$get_body_equ_coords($i), $observer, $i)->get_alt();
    }
  }

  # sort hash by value
  my(@l) = sort {$alts{$a} <=> $alts{$b}} (keys %alts);
  # and return desired value
  if ($minmax==-1) {return $l[0];}
  if ($minmax==+1) {return $l[$#l];}
}

=item get_body_rst_horizon3($jd, $observer, $get_body_equ_coords, $horizon)

For Julian day $jd and observer $observer, give the rise/set/transit
times of body whose coordinates are given by the function
$get_body_equ_coords; rise and set are computed relative to $horizon

NOTE: $jd should be an integer
TODO: assumes bodys elevation is fairly unimodal 

TODO: what is get_dynamical_time_diff() and why do I need it?
TODO: handle multiple rise/sets in a given day
TODO: this gives time of highest elevation as "transit", not true transit

TODO: this subroutine is slow; can speed up (at expense of accuracy)
by tweaking findmax/findmin

=cut

sub get_body_rst_horizon3 {
  my($jd, $observer, $get_body_equ_coords, $horizon) = @_;
  # thing Im going to return
  my($ret) = Astro::Nova::RstTime->new();
  # to the nearest second (sheesh)
  my($precision) = 1/86400;

  # find bodys min/max alt times and altitudes (above horizon) at those times
  my($mintime) = get_body_minmax_alt($jd, $observer, $get_body_equ_coords, -1);
  my($maxtime) = get_body_minmax_alt($jd, $observer, $get_body_equ_coords, +1);
  my($minalt) = get_hrz_from_equ(&$get_body_equ_coords($mintime), $observer, $mintime)->get_alt()-$horizon;
  my($maxalt) = get_hrz_from_equ(&$get_body_equ_coords($maxtime), $observer, $maxtime)->get_alt()-$horizon;

  debug("RANGE: $mintime,$maxtime,$minalt,$maxalt", get_hrz_from_equ(&$get_body_equ_coords($jd), $observer, $jd)->get_alt()-$horizon, get_hrz_from_equ(&$get_body_equ_coords($jd+1), $observer, $jd+1)->get_alt()-$horizon);

  # circumpolar conditions ($minalt/$maxalt gives elevation ABOVE horizon)
  if ($maxalt < 0) {return -1;}
  if ($minalt > 0) {return +1;}

  # bodys elevation at time t under given conditions
  my($f) = sub {get_hrz_from_equ(&$get_body_equ_coords($_[0]), $observer, $_[0])->get_alt()-$horizon};

  # if $mintime < $maxtime, find rise efficiently, set inefficiently
  my($rise,$set);
  if ($mintime < $maxtime) {
    $rise = findroot2($f, $mintime, $maxtime,0, "delta=$precision");
    # set may occur from start of day to nadir or zenith to end of day
    # TODO: it can actually be BOTH!
    $set = findroot2($f, $jd, $mintime,0, "delta=$precision");
    debug("ALTSET", findroot2($f,$maxtime,$jd+1,0,"delta=$precision"));
    # if that returned nothing...
    unless ($set) {$set = findroot2($f,$maxtime,$jd+1,0,"delta=$precision");}
  } else {
    # if $maxtime < $mintime, find set efficiently, rise inefficiently
    $set = findroot2($f, $maxtime, $mintime,0,"delta=$precision&comment=alpha");
    # rise is from start of day to zenith or from nadir to end of day
    $rise = findroot2($f, $jd, $maxtime,0, "delta=$precision");
    unless ($rise) {$rise = findroot2($f,$mintime,$jd+1,0,"delta=$precision");}
  }

  # TODO: this could be more efficient methinks
  $ret->set_rise($rise);
  $ret->set_set($set);
  $ret->set_transit($maxtime);

  # TODO: I can return more here, including maxalt, minalt, nadir time, etc
  return $ret;
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
