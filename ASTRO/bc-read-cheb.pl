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
	    "uranus:387:6:1", "neptune:405:6:1", "whocares:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2");

# TODO: this should NOT be defined here!!!

for $i (@planets) {
  my($plan,$pos,$num,$chunks) = split(/:/, $i);
  $planetinfo{$plan} = [$pos,$num,$chunks];
}

# an entire year or so of mars

$planet = "mars";
for ($time=str2time("2000-01-01"); $time<=str2time("2038-01-01");
     $time+=86400*32) {

  $count++;
  my(%arr) = planet_chebyshev($time, $planet);
  map(s/D/e/, @{$arr{jd}});
  map($_=jd2unix($_,"jd2unix"), @{$arr{jd}});
  my($us,$ue) = @{$arr{jd}};

  for $i ("x","y","z") {
    my(@coords) = @{$arr{$i}};

    # change to fractions for mathematica "precision"
    map(s%\.(\d{16})\D%$1/10^17*10^%, @coords);

    @terms = ();
    for $j (0..$#coords) {
#      push(@terms, "$coords[$j]*ChebyshevT[$j,(t-$us)/32/86400*2-1]");
      push(@terms, "$coords[$j]*ChebyshevT[$j,t]");
    }

    # the polynomial
    my($poly) = join("+\n", @terms);

    # define this function independently as well
    print "chunk[$planet][$i][$count][t_] = $poly;\n";
    print "chunkd1[$planet][$i][$count][t_] = D[$poly,t];\n";
    print "chunkd2[$planet][$i][$count][t_] = D[$poly,t,t];\n";
    print "chunkd3[$planet][$i][$count][t_] = D[$poly,t,t,t];\n";
    print "chunkd4[$planet][$i][$count][t_] = D[$poly,t,t,t,t];\n";

    print "pos[$planet][$i][t_/;t>=$us&&t<$ue] = chunk[$planet][$i][$count][(t-$us)/32/86400*2-1];\n";

    for $j ("d1","d2","d3","d4") {
      print "pos${j}[$planet][$i][t_/;t>=$us&&t<$ue] = chunk${j}[$planet][$i][$count][(t-$us)/32/86400*2-1];\n";
    }
  }
}

die "TESTING";

# this is hardcoded for 2016-12-22 00:00:00 to 2017-01-23 00:00:00
my($us,$ue) = (1482364800, 1485129600);


# debug(unfold(%arr));

die "TESTING";

for $test ("-0.4821770431983586D-01", "-0.6233219171917435D+07", "0.3822701245044369D+04") {
  debug(bin2cheb(cheb2bin($test)));
}

$aa = cheb2bin("-0.1611214918998700D-07");
$ab = cheb2bin("0.1611214918998700D-07");

debug(bin2cheb($aa));

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

warn "TESTING"; return;




  debug("SIGN: $sign");
  # put exponent in Perl format
  if ($sign&32) {$exp="-$exp";} else {$exp="+$exp";}

  my($ret);


  debug(sprintf("%0.fe$exp", $ret));

  # TODO: this may be inaccurate in Perl (floating point limits)
  return "${ret}e$exp";

  # this probably won't work
  debug("RET/EXP: $ret/$exp");
  $ret*=10**$exp;
  debug(sprintf("%0.f", $ret));

#  debug(sprintf("%0.f %d", $ret, $exp));

warn "FOO: TESTING";
  return;

  # extract relevant parts
  $coeff=~s/^(.*?)0\.(.*?)D(.)(..)//||warn("BAD COEFF: $coeff");
  my($sgn, $man, $esgn, $exp) = ($1,$2,$3,$4);
  # the last byte combines the exponent, and the sign of both exponent/mantissa
  my($lastbyte) = chr(($sgn eq "-"?64:0)+($esgn eq "-"?32:0)+$exp);
  return join("",map($_=chr($_),num2base($man,256)))."$lastbyte";
}



open(A,"bzcat /home/barrycarter/BCGIT/ASTRO/ascp1950.430.bz2|");

# will end with explicit exit
for (;;) {
  my($buf);

  # file is very well formatted, each 26873 bytes is one section
  read(A, $buf, 26873);
  # split into numbers
  my(@nums) = split(/\s+/s, $buf);
  # convert to Perl (16 digit precision, -10 lowest mantissa +4 for safety)
  map(s/^(.*?)D(.*)$/sprintf("%.30f",$1*10**$2)/e, @nums);
#  map(s/^(.*?)D(.*)$/$1*10^$2/, @nums);

  # first four: section number, number of data points, julian start, julian end
  my($bl, $sn, $nd, $js, $je) = splice(@nums,0,5);

  # only 2014 for now (2456658.5 - 2456658.5+365)
  if ($je < 2456658.5) {next;}
  if ($js > 2456658.5+365) {last;}
  debug("$js - $je");
  # length of interval
  my($in) = $je-$js;

  # and now the planet list
  for $i (@planets) {
    # I don't actually use $spos, since I'm splicing
    my($pl, $spos, $ncoeff, $sects) = split(/:/, $i);
    # days per interval
    my($days) = $in/$sects;
    # loop through each section
    for $j (1..$sects) {
      # nth set of coefficients for this planet
      $coeffset{$pl}++;
      for $k ("x","y","z") {
	@coeffs = splice(@nums,0,$ncoeff);
	# TODO: only printing mercury x for now (mathematica stuff)
	if ($k eq "x" && $pl eq "mercury") {
	  # now including start/end dates
	  $list = join(", ",($js+$days*($j-1), $js+$days*$j, @coeffs));
	  print "$pl\[$k\][$coeffset{$pl}] = {$list};\n";
	}
      }
    }
  }
}

