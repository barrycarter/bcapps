#!/bin/perl

# libnova playing

require "/usr/local/lib/bclib.pl";

# TEST CODE
# $observer = Astro::Nova::LnLatPosn->new("lng"=>-106,"lat"=>35);
# $rst = get_body_rst_horizon2(2456614,$observer,\&get_lunar_equ_coords, 1/8.);
# debug($rst->get_rise(), $rst->get_transit(), $rst->get_set());

=item get_body_rst_horizon2($jd, $observer, $get_body_equ_coords, $horizon)

For Julian day $jd and observer $observer, give the rise/set/transit
times of body whose coordinates are given by the function
$get_body_equ_coords; rise and set are computed relative to $horizon

NOTE: $jd should be an integer
TODO: assumes bodys elevation is fairly unimodal 

TODO: what is get_dynamical_time_diff() and why do I need it?
TODO: handle multiple rise/sets in a given day

TODO: this subroutine is slow; can speed up (at expense of accuracy)
by tweaking findmax/findmin

=cut

sub get_body_rst_horizon2 {
  my($jd, $observer, $get_body_equ_coords, $horizon) = @_;
  # thing Im going to return
  my($ret) = Astro::Nova::RstTime->new();

  # TODO: this should be a parameter or something (1/86400. = 1 sec)
  my($precision) = 1/1440.;

  # body's ra/dec at $jd+.5
  my($pos) = &$get_body_equ_coords($jd+.5);

  # local siderial time at midday JD (midnight GMT, 5pm MST, 6pm MDT)
  my($lst) = fmodp(get_apparent_sidereal_time($jd+.5)+$observer->get_lng()/15,24);
  # approximate transit/zenith time of body (as fraction of day)
  my($att) = fmodp(0.5+($pos->get_ra()/15-$lst)/24,1);
  # fairly inaccurate (but that's OK) nadir time
  my($atn) = fmodp($att+.5,1);

  # altitude of body (above horizon) for $observer at given time
  my($f) = sub {get_hrz_from_equ(&$get_body_equ_coords($_[0]), $observer, $_[0])->get_alt()-$horizon};

  # the max altitude should occur within 6h of the approximate transit
  # time, but disallow crossing the day line
  my($s) = $jd + max($att-.25,0);
  my($e) = $jd + min($att+.25,1);
  my($maxtime) = findmax($f, $s, $e, $precision);
  my($maxalt) = &$f($maxtime);

  # same for min altitude
  $s = $jd + max($atn-.25,0);
  $e = $jd + min($atn+.25,1);
  my($mintime) = findmin($f, $s, $e, $precision);
  my($minalt) = &$f($mintime);

  # circumpolar conditions (recall $f gives elevation ABOVE horizon)
  if ($maxalt < 0) {return -1;}
  if ($minalt > 0) {return +1;}

  # if $mintime < $maxtime, find rise efficiently, set inefficiently
  my($rise,$set);
  if ($mintime < $maxtime) {
    $rise = findroot($f, $mintime, $maxtime, $precision);
    # set may occur from start of day to nadir or zenith to end of day
    # TODO: it can actually be BOTH!
    $set = findroot($f, $jd, $mintime, $precision);
    # if that returned nothing...
    unless ($set) {$set = findroot($f, $maxtime, $jd+1, $precision);}
  } else {
    # if $maxtime < $mintime, find set efficiently, rise inefficiently
    $set = findroot($f, $maxtime, $mintime, $precision);
    # rise is from start of day to zenith or from nadir to end of day
    $rise = findroot($f, $jd, $maxtime, $precision);
    unless ($rise) {$rise = findroot($f, $mintime, $jd+1, $precision);}
  }

  # TODO: this could be more efficient methinks
  $ret->set_rise($rise);
  $ret->set_set($set);
  $ret->set_transit($maxtime);

  # TODO: I can return more here, including maxalt, minalt, nadir time, etc
  return $ret;
}

1;
