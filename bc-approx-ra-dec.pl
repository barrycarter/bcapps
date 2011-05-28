#!/bin/perl

# Given frequently measured RA/DEC information, find out how many
# measurements I need to create an accurate spline

require "bclib.pl";

# these files not in GIT, see http://data.barrycarter.info/planets/
open(A,"bzcat /home/barrycarter/BCINFO/sites/DATA/planets/mars.csv.bz2|");

# $n = fraction of observations we want to preserve
$n = 8;

# store data we want to preserve
# TODO: ugly to keep whole list when we only need 4 elts at a time?

while (<A>) {

  chomp($_);
  # $w = data we don't want
  my($time, $w, $w, $ra,$dec) = split(/\,\s*/, $_);

  # store actual ra and dec
  ($ra{$time}, $dec{$time}) = ($ra, $dec);

  # skip most data for interpolation
  if ($count++%$n) {next;}

  # store data to interpolate later (zval is really like yval2)
  ($y, $z) = radec2vector($ra,$dec);

  # testing
  ($tra, $tdec) = vector2radec($y, $z);
  debug("$ra/$dec -> $tra/$tdec");


  push(@xvals, $time);
  push(@yvals, $y);
  push(@zvals, $z);
}

close(A);

die "TESTING";

# now, to compare the approx to the actual values
for $i (sort {$a <=> $b} keys %ra) {
  # the interpolations
  $inty = hermione($i, \@xvals, \@yvals);
  $intz = hermione($i, \@xvals, \@zvals);

  # convert back to RA/DEC
  ($ra, $dec) = vector2radec($inty, $intz);

  # compare
  debug("$i: $ra/$dec vs $ra{$i}, $dec{$i}");
}


die "TESTING";

debug("X",@xvals,"Y",@yvals,"Z",@zvals);

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
