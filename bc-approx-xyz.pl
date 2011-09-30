#!/bin/perl

# use "hermione" interpolation for XYZ values of planets, omitting as
# many data as possible while still preserving some accuracy

# based on bc-approx-ra-dec.pl, but simpler since we're storing raw values

require "bclib.pl";

# not in GIT, sorry
open(A,"bzcat /home/barrycarter/20110916/final-pos-500-0-301.txt.bz2|");

# $n = fraction of observations we want to preserve
$n = 10;
$count = -1;

while (<A>) {

  $count++;
  if ($count%10000==0) {debug("COUNT: $count");}

  chomp($_);

  # the first line is useless
  if (/planet/) {next;}

  # nuke brackets
  s/[{}]//g;

  # E+
  s/\*10\^/E/isg;

  # $w = data we don't want
  # TODO: this is a bizarre way of converting "1e+3" to "1000"
  my($w, $time, $x, $y, $z) = map($_=1.*$_, split(/\,\s*/, $_));

  # avoid dupes
  if ($x{$time} || $y{$time} || $z{$time}) {$count--; next;}

  # store actual ra and dec
  ($x{$time}, $y{$time}, $z{$time}) = ($x, $y, $z);

  # skip most data for interpolation
  if ($count%$n) {next;}

#  print "PUSHING TO XVALS: $x, TIME: $time\n";
  push(@xvals, $x);
  push(@yvals, $y);
  push(@zvals, $z);
}

close(A);

@times = sort {$a <=> $b} keys %x;

# now, to compare the approx to the actual values
# we don't claim accuracy on the first $n and last 2*$n entries
for $i ($n..$#times-2*$n) {
  my($time) = $times[$i];

  # where in interval?
  $intloc = ($i%$n)/$n;
  $intv = int($i/$n);

  # local interpolation faster than hermione()
  $intx = hermm1($intloc)*$xvals[$intv-1] +
    herm0($intloc)*$xvals[$intv] +
      hermp1($intloc)*$xvals[$intv+1] +
	hermp2($intloc)*$xvals[$intv+2];

  $inty = hermm1($intloc)*$yvals[$intv-1] +
    herm0($intloc)*$yvals[$intv] +
      hermp1($intloc)*$yvals[$intv+1] +
	hermp2($intloc)*$yvals[$intv+2];

  $intz = hermm1($intloc)*$zvals[$intv-1] +
    herm0($intloc)*$zvals[$intv] +
      hermp1($intloc)*$zvals[$intv+1] +
	hermp2($intloc)*$zvals[$intv+2];

  my($diffx) = $intx-$x{$times[$i]};
  my($diffy) = $inty-$y{$times[$i]};
  my($diffz) = $intz-$z{$times[$i]};

#  print "INTLOC: $intloc, INTV: $intv, XATINTV: $xvals[$intv]\n";
#  print "$intx vs $x{$time} at $time\n";

  $maxx = max($maxx,abs($diffx));
  $maxy = max($maxy,abs($diffy));
  $maxz = max($maxz,abs($diffz));

  $truemaxx = max($truemaxx, abs($x{$times[$i]}));
  $truemaxy = max($truemaxy, abs($y{$times[$i]}));
  $truemaxz = max($truemaxz, abs($z{$times[$i]}));

  if ($i%10000==0) {
    debug("MAXSOFAR: $maxx/$maxy/$maxz vs $truemaxx/$truemaxy/$truemaxz");
  }
}

debug("FINAL: $maxx/$maxy/$maxz");


