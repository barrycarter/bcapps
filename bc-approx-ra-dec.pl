#!/bin/perl

# Given frequently measured RA/DEC information, find out how many
# measurements I need to create an accurate spline

require "bclib.pl";

# these files not in GIT, see http://data.barrycarter.info/planets/
open(A,"bzcat /home/barrycarter/BCINFO/sites/DATA/planets/moon.csv.bz2|");

# $n = fraction of observations we want to preserve
$n = 10*15;
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

debug("FINAL: $maxra/$maxdec");

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

=item RESULTS

MERCURY:
 daily: 0.000247459432500818/0.000139043397140881
 weekly: 0.385409711937996/0.190355235843001

VENUS:
 daily: 9.40244528635503e-06/1.21894724784966e-05
 weekly: 0.0205220785349525/0.0244215836384747

SATURN:
 weekly: 7.98775800774365e-05/3.480178203219e-05
 monthly: 0.0133377797627645/0.00762339993226746

MOON:
 daily: 0.0216295941092142/0.0625815265411127
 hourly: 1.62663212677217e-07/2.83467034734031e-07
 12h: 0.00143659083431658/0.00406598129115565
 18h:  0.00703938682514149/0.020151070523486
 16h: 0.00447947833418993/0.0126908556469871
 15h: 0.00344133104550792/0.00988136583707799

=cut

