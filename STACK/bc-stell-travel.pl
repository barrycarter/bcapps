#!/bin/perl

# https://astronomy.stackexchange.com/questions/20018/stellarium-simulation

require "/usr/local/lib/bclib.pl";

# Rampart House YT Canada: 67.4162010798574, -140.988673030655
# Menton France: 43.7764861450485, 7.50434920217688
# TODO: its actually 4578.99869985371, fix roundoff in gcdist alias
# Distance (per gcdist, to confirm below): 4578 mi

# TODO: make these arguments
my(@epos) = (67.4162010798574, -140.988673030655);
my(@spos) = (43.7764861450485, 7.50434920217688);
# start time chosen as "now", be more clever here
my($stime) = 1486684800;
# speed of sound (miles per hour) -- this is Mach 1
my($speed) = 767.269;

# program starts here; above is config options

my($dist) = gcdist(@spos,@epos);

# mile by mile path

for $i (0..floor($dist+1)) {

  # latitude/longitude for this mile
  my($rlat,$rlon) = gcstats(@spos,@epos,$i/$dist);

  # TODO: fix gcstats per below
  # this is just clean, gcstats returns 0 <= rlon <= 360
  $rlon = fmodn($rlon,360);

  # time
  my($t) = $stime + $i/$speed*3600;

  # time in stellarium format
  my($t2) = strftime("%Y:%m:%dT%H:%M:%S", gmtime($t));

  push(@cmds, "core.setDate('$t2')");
  # TODO: elevation could be non-zero here, cruising altitude?
  my($loc) = sprintf("LAT: %0.4f, LON: %0.4f", $rlat, $rlon);
  # 10000m ~ 30K ft
  push(@cmds, "core.setObserverLocation($rlon,$rlat,10000,0,'$loc','Earth')");

  # TODO: this is only for testing
  push(@cmds, "core.wait(.02)");

  debug("P: $rlat, $rlon, T: $t2");
}

print join(";\n",@cmds),"\n";

