#!/bin/perl

# reads the Chebyshev coefficients from ascp1950.430.bz2

# NOTE: must use: reference plane=FRAME under "Table settings" to get
# answers that agree here; the Chebyshev polynomials are evaluated
# from -1 to +1

# This helps find limits, which are -15 to +10, inclusive
# bzcat ascp1950.430.bz2 | perl -nle 'while (s/D(...)//) {print $1}' | sort | uniq
# can represent: 10^-31 to 10^10 with 16 digits of precision

require "/usr/local/lib/bclib.pl";

# list of planets with hardcoded coefficient numbers/etc
# TODO: don't hardcode, use header.430_572

# saturn pos at JD 32-day break mark
# 2457776.500000000, A.D. 2017-Jan-23 00:00:00.0000,
# -2.619630026472111E+08, -1.479262345684487E+09, 3.614600451880660E+07

# and mars:
# 2457776.500000000 = A.D. 2017-Jan-23 00:00:00.0000 (CT)
# 1.872704779146366E+08  1.048557408105275E+08 -2.422463501688972E+06

# earthmoon = earth-moon barycenter
# moongeo = position of moon from earth

@planets = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "pluto:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2");

# TODO: this should NOT be defined here!!!

for $i (@planets) {
  my($plan,$pos,$num,$chunks) = split(/:/, $i);
  $planetinfo{$plan} = [$pos,$num,$chunks];
}



# for mathematica, obtain raw coefficients for planets for 100 years

open(A,"/home/barrycarter/20140124/ascp1950.430");

for $planet (keys %planetinfo) {
  my(@all) = ();
  my($pos,$num,$chunks) = @{$planetinfo{$planet}};

  # 1142 based on file size of 30688966 divided by 26873 per chunk
  for $i (0..1141) {
    seek(A, $i*26873, SEEK_SET);
    read(A, my($data), 26873);
    my(@data) = split(/\s+/, $data);
    @data = @data[$pos+2..$pos+2+$num*$chunks*3-1];
    map(s%\.(\d{16})\D%$1/10^16*10^%, @data);
    push(@all,@data);
  }

  my($all) = join(",\n",@all);
  open(B,">/home/barrycarter/20140823/raw-$planet.m");
  print B << "MARK";
ncoeff = $num;
ndays = 32/$chunks;
coeffs = {$all};
MARK
  ;
  close(B);
}

close(A);

=item planet_chebyshev($time,$planet)

Obtain the Chebyshev coefficients (as a hash of 3 lists, for x y z)
for $planet at $time (Unix seconds). Requires ascp1950.430.bz2 (which
is somewhere on NASAs/JPLs site, though I cant find it at the moment).

Also returns other useful info in hash

NOTES:

First chunk (1 1801) starts at -632707200 and ends at -629942400 (32 days)

TODO: this only works for planets with 32-day coefficients for now

=cut

sub planet_chebyshev {
  my($time,$planet) = @_;
  local(*A);
  my(%rethash);

  # TODO: define planetinfo hash properly locally (dont do below)
  my($pos,$num,$chunks) = @{$planetinfo{$planet}};

  # TODO: currently using uncompressed copy, change to use bzip'd copy
  # TODO: when using bzip, using .tab file to seek more efficiently
  # TODO: opening this each time is inefficient, allow for mass grabs?
  # TODO: should I be using DE431?
  open(A,"/home/barrycarter/20140124/ascp1950.430");

  # where in file is time? First find chunk (chunk-1 actually)
  my($chunk) = floor(($time+632707200)/32/86400);
  # seek there (each chunk = 26873 bytes) and read
  seek(A, $chunk*26873, SEEK_SET);
  # TODO: can seek even more precisely to exact position
  read(A, my($data), 26873);

  # the coefficients, chunk number, dates, etc
  my(@data) = split(/\s+/, $data);

  # the data we actually want (+3 to get rid of blanks and chunk numbers)
  @data = @data[3..4,$pos+2..$pos+2+$num*3];
  $rethash{jd} = [splice(@data,0,2)];
  for $i ("x","y","z") {$rethash{$i} = [splice(@data,0,$num)];}
  return %rethash;
}

=item cheb2bin

Given a Chebyshev coefficient (like -0.9503118187993631D+07 convert it
to a 7-byte string)

=cut

sub cheb2bin {
  my($coeff) = @_;

  # extract relevant parts
  $coeff=~s/^(.*?)0\.(.*?)D(.)(..)//||warn("BAD COEFF: $coeff");
  my($sgn, $man, $esgn, $exp) = ($1,$2,$3,$4);
  # the last byte combines the exponent, and the sign of both exponent/mantissa
  my($lastbyte) = chr(($sgn eq "-"?64:0)+($esgn eq "-"?32:0)+$exp);
  # TODO: below does not handle trailing 0s
  return join("",map($_=chr($_),num2base($man,256)))."$lastbyte";
}

=item bin2cheb

Given a 7-byte string, return the associated Chebyshev coefficient
(like -0.9503118187993631D+07)

This function returns a string, not a double, because Perls default
double precision routines are insufficiently precise.

=cut

sub bin2cheb {
  my($str) = @_;
  my($ret);

  # the mantissa
  my(@mant) = map($_=ord($_),split(//, $str));

  # NOTE: last entry is sign/exponent, not part of mantissa
  my($sign) = pop(@mant);

  for $i (0..$#mant) {
    $ret += $mant[$i]*256**$i;
    debug("RETNOW: $mant[$i]/$i",sprintf("%0.f",$ret));
}
  debug(sprintf("%0.f", $ret));
  # convert to non-engineering format
  $ret = sprintf("0.%0.f", $ret);

  # find the exponent
  my($exp) = sprintf("%0.2d", $sign%16);
  # signs <h>(signs, signs, everywhere a sign, blocking up the scenery...)</h>
  if ($sign&32) {$exp="-$exp";} else {$exp="+$exp";}

  # can't multiple $ret by -1, loses precision, so...
  if ($sign&64) {
    debug("-${ret}D$exp");
  } else {
    debug("${ret}D$exp");
  }
}
