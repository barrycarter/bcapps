#!/bin/perl

# Given frequently measured RA/DEC information, find out how many
# measurements I need to create an accurate spline

require "bclib.pl";

# these files not in GIT, see http://data.barrycarter.info/planets/
open(A,"bzcat /home/barrycarter/BCINFO/sites/DATA/planets/mars.csv.bz2|");

# $n = fraction of observations we want to preserve
$n = 8;
$count = -1;

# store data we want to preserve
# TODO: ugly to keep whole list when we only need 4 elts at a time?
while (<A>) {

  $count++;
  if ($count%10000==0) {debug("COUNT: $count");}

  chomp($_);

  # $w = data we don't want
  my($time, $w, $w, $ra,$dec) = split(/\,\s*/, $_);

  # avoid dupes
  # NOTE: fails in the case where 0,0 is duplicated
  if ($ra{$time} && $dec{$time}) {$count--; next;}

  # store actual ra and dec
  ($ra{$time}, $dec{$time}) = ($ra, $dec);

  # store data to interpolate later (zval is really like yval2)
  ($y, $z) = radec2vector($ra,$dec);

  # skip most data for interpolation (calculating y/z above just for testing)
  if ($count%$n) {next;}

  push(@xvals, $time);
  push(@yvals, $y);
  push(@zvals, $z);
}

close(A);

@times = sort {$a <=> $b} keys %ra;

# now, to compare the approx to the actual values
# we don't claim accuracy on the first $n and last 2*$n entries
for $i ($n..$#times-2*$n) {
  my($time) = $times[$i];

  # where in interval?
  $intloc = ($i%$n)/$n;
  $intv = int($i/$n);

  # local interpolation faster than hermione()
  $inty = hermm1($intloc)*$yvals[$intv-1] +
    herm0($intloc)*$yvals[$intv] +
      hermp1($intloc)*$yvals[$intv+1] +
	hermp2($intloc)*$yvals[$intv+2];

  $intz = hermm1($intloc)*$zvals[$intv-1] +
    herm0($intloc)*$zvals[$intv] +
      hermp1($intloc)*$zvals[$intv+1] +
	hermp2($intloc)*$zvals[$intv+2];

  # convert back to RA/DEC
  ($ra, $dec) = vector2radec($inty, $intz);

  my($diffra) = $ra-$ra{$times[$i]};
  # 180 and 360 are intentionally different numbers below
  if ($diffra>180) {$diffra-=360;}
  if ($diffra<-180) {$diffra+=360;}

  print sprintf("%0.10f\n",$diffra);

  $diffra = abs($diffra);
  my($diffdec) = abs($dec-$dec{$times[$i]});

  $maxra = max($maxra,$diffra);
  $maxdec = max($maxdec,$diffdec);

  if ($i%10000==0) {
    debug("MAXSOFAR: $maxra/$maxdec");
  }
}

# convert radec to the weird format I store it in (vector of length
# pi/2+dec and angle ra)

sub radec2vector {
  my($ra,$dec) = @_;
  my($len) = ($PI/2+$dec/180*$PI);
  my($ang) = $ra/180*$PI;
  return ($len*cos($ang), $len*sin($ang));
}

# reverse of above

sub vector2radec {
  my($x,$y) = @_;
  my($ra) = atan2($y,$x)*180/$PI;
  my($dec) = (sqrt($x*$x+$y*$y)-$PI/2)*180/$PI;
  if ($ra<0) {$ra+=360;}
  return ($ra,$dec);
}
