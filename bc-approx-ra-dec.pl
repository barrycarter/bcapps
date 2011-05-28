#!/bin/perl

# Given frequently measured RA/DEC information, find out how many
# measurements I need to create an accurate spline

require "bclib.pl";

# these files not in GIT, see http://data.barrycarter.info/planets/
open(A,"bzcat /home/barrycarter/BCINFO/sites/DATA/planets/mars.csv.bz2|");

# $n = fraction of observations we want to preserve
$n = 8;

@data = ();
for $i (1..$n) {
  # NOTE: putting my($data) below doesn't work
  $data = <A>;
  chomp($data);
  # $x = data we don't want
  my($time, $x, $x, $ra,$dec) = split(/\,\s*/, $data);
  # should really be a list of 2-element lists, but...
  push(@data, $ra, $dec);
}

# encode the first/last piece of @data, interpolate the rest
@first = radec2vector($data[0], $data[1]);
# <h>last is probably a reserved keyword, but who cares</h>
@last = radec2vector($data[-2], $data[-1]);



debug(@first,@last);

# convert radec to the weird format I store it in (vector of length
# pi/2+dec and angle ra)

sub radec2vector {
  my($ra,$dec) = @_;
  my($len) = ($PI/2+$dec/180*$PI);
  my($ang) = $ra/180*$PI;
  return ($len*cos($ang), $len*sin($ang));
}

