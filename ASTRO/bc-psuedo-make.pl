#!/bin/perl

# I can't get make to do what I want (but could if I tried harder),
# this hack works around it

require "/usr/local/lib/bclib.pl";

for $i (glob("*.c")) {

  my($targ) = $i;
  $targ=~s%^(.*?)\.c$%/home/barrycarter/bin/$1%isg;

  # if targ is more recent, ignore
  my($targtime) = -M $targ;
  if ($targtime && $targtime < -M $i) {next;}

  # else compile
  my($cmd) = "gcc -std=gnu99 -Wall -O2 -I /home/barrycarter/SPICE/cspice/include $i -o $targ /home/barrycarter/SPICE/cspice/lib/cspice.a -lm";
  debug($cmd);

  print "Making: $i -> $targ\n";

  my($out,$err,$res) = cache_command2($cmd);

  # even if make ok, return warnings
  print "$out\n$err\n$res\n";

}

