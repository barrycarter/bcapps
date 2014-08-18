#!/bin/perl

# reads the Chebyshev coefficients from ascp1950.430.bz2

# This helps find limits, which are -15 to +10, inclusive
# bzcat ascp1950.430.bz2 | perl -nle 'while (s/D(...)//) {print $1}' | sort | uniq
# can represent: 10^-31 to 10^10 with 16 digits of precision

require "/usr/local/lib/bclib.pl";

# list of planets with hardcoded coefficient numbers/etc
# TODO: don't hardcode, use header.430_572


# some saturn data:
# 2457754.500000000, A.D. 2017-Jan-01 00:00:00.0000,
# -2.790167302332390E+08, -1.475897564189129E+09, 3.676598655656585E+07

@planets = ("mercury:3:14:4", "venus:171:10:2", "earthmoon:231:13:2",
	    "mars:309:11:1", "jupiter:342:8:1", "saturn:366:7:1",
	    "uranus:387:6:1", "neptune:405:6:1", "whocares:423:6:1",
	    "moongeo:441:13:8", "sun:753:11:2");

my($time) = str2time("2017-01-01");
my(@arr) = planet_chebyshev($time, "saturn");

my(@arr2) = @{$arr[0]};

debug("ARR2",@arr2);

map(s/D/*10^/, @{$arr[0]});

# for $i (0..6) {
#  push(@out,@{$arr[0]}[$i]."*ChebyshevT[$i,0]");
# }

for $i (7..13) {
  push(@out,@{$arr[0]}[$i]."*ChebyshevT[$i-7,0]");
}

print join("+\n", @out),"\n";


die "TESTING";

for $test ("-0.4821770431983586D-01", "-0.6233219171917435D+07", "0.3822701245044369D+04") {
  debug(bin2cheb(cheb2bin($test)));
}




$aa = cheb2bin("-0.1611214918998700D-07");
$ab = cheb2bin("0.1611214918998700D-07");

debug(bin2cheb($aa));

=item planet_chebyshev($time,$planet)

Obtain the Chebyshev coefficients (as 3 lists, for x y z) for $planet
at $time (Unix seconds). Requires ascp1950.430.bz2 (which is somewhere
on NASAs/JPLs site, though I cant find it at the moment).

Also returns a 4th list with metadata

NOTES:

First chunk (1 1801) starts at -632707200 and ends at -629942400 (32 days)

=cut

sub planet_chebyshev {
  my($time,$planet) = @_;
  local(*A);

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
  debug("DATA: $data");

  # compact data and get rid of newlines (probably inefficient)
  $data=~s/\s+/ /g;

  # the coefficients, chunk number, dates, etc
  my(@data) = split(/\s+/, $data);

  # the chunk numbers
  my($blank, $chunk, $total) = (shift(@data), shift(@data), shift(@data));
  debug("JD: $data[0] $data[1]");
  for $i (0..$#data) {debug("DATA[$i]: $data[$i]");}

  # for saturn (testing)
  # 365 = the 366th list element (0-based array)
  return [@data[365..371],@data[372..378],@data[379..385]];
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

