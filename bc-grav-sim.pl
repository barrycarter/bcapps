#!/bin/perl

# Simulates Sun/Earth/Moon system

require "bclib.pl";

# mass in kg

# xyz at the epoch (2011-01-01 0000 UTC) wrt solar system barycenter
# in km (xy is the ecliptic plane, x is direction to vernal equinox J2000.0)

# (dx/dy/dz in km/s)

# TODO: naming objects individually is inefficient

# simplified ellipse for testing

%sun = ("mass" => 10**2); # all others to 0

%earth = ("mass" => 1, "x" => 100, "dy" => 1); # all others 0

# gravitational constant in km^3kg^-1s^-2
$g = 6.6742867*10**-20;

# test grav
$g = 1;

debug("BEFORE", %earth);

$step = 0.1;
# $total = 365*86400;
$total = 144*4;

for $i (1..$total/$step) {
  twobod(\%earth, \%sun, $step);
#  twobod(\%earth, \%moon, $step);
#  twobod(\%sun, \%moon, $step);
  update_pos($step);
  # I use gnuplot to graph the result as a test
  print "$earth{x} $earth{y}\n";
}

debug("AFTER", %earth);

# update positions (but not velocities) for all objects for $n seconds

sub update_pos {
  my($n) = @_;
  for $i (\%sun, \%earth, \%moon) {
    for $j ("x".."z") {
      $i->{$j} += $n*$i->{"d$j"};
    }
  }
}

# Given two bodies (hashref), update their velocities in an $n-second increment
sub twobod {
  my($a, $b, $n) = @_;

  # compute distance squared and vector b-a (from a to b), and update
  # positions based on current velocity
  my($dist2);
  my(%vec);
  for $i ("x".."z") {
    # the $i component of the vector pointing from a to b
    $vec{$i} = $b->{$i} - $a->{$i};
    # the contribution to d2 from this coordinate
    $dist2 += $vec{$i}**2;
  }

  # change in velocity for objects a and b
  # $vec/sqrt($dist2) is a unit vector
  for $i ("x".."z") {

    # velocity change for object $a, $b
    my($dva) = $vec{$i}*$b->{mass}/$dist2/sqrt($dist2)*$g*$n;
    my($dvb) = $vec{$i}*$a->{mass}/$dist2/sqrt($dist2)*$g*$n;

    debug("For $i, $dva, $dvb");

    $a->{"d$i"} += $dva;
    $b->{"d$i"} -= $dvb;
  }
}

=item comment

Moon expected values 1 day later:

2455563.500000000 = A.D. 2011-Jan-02 00:00:00.0000 (CT)
  -2.898254462146430E+07  1.441108363677881E+08 -1.342760268678171E+04
  -2.876163759476320E+01 -6.185255673182021E+00  8.705179950864851E-02
   4.903269803876556E+02  1.469963306741331E+08 -3.930580570702767E-01

1 sec later:

2455562.500011574 = A.D. 2011-Jan-01 00:00:01.0000 (CT)
  -2.648943420299003E+07  1.446321220704001E+08 -2.055331369653119E+04
  -2.895706536736777E+01 -5.878203571101682E+00  7.710571333769170E-02
   4.904656094840852E+02  1.470378906317020E+08 -5.653125402607160E-01

Earth expected values 1 day later:

2455563.500000000 = A.D. 2011-Jan-02 00:00:00.0000 (CT)
  -2.886750722991675E+07  1.444752444198366E+08 -1.276216896790233E+03
  -2.972917407480583E+01 -5.838757776322613E+00 -8.452135575557206E-04
   4.914433812194709E+02  1.473310192236162E+08  9.944404007629937E-02

1 sec later:

2455562.500011574 = A.D. 2011-Jan-01 00:00:01.0000 (CT)
  -2.629472145590306E+07  1.449571016816709E+08 -1.207458600375961E+03
  -2.982508990736482E+01 -5.315228224683068E+00 -7.367100656885886E-04
   4.914155833955840E+02  1.473226856456661E+08  9.341639486128177E-02

1 year later:

2455927.500000000 = A.D. 2012-Jan-01 00:00:00.0000 (CT)
  -2.550064610897278E+07  1.447622482848566E+08 -4.698334192011960E+03
  -2.983135934934849E+01 -5.196145052289108E+00  4.548998721932875E-04
   4.903096237727032E+02  1.469911272918739E+08  5.791706991641320E-02

Sun expected values 1 day later:

2455563.500000000 = A.D. 2011-Jan-02 00:00:00.0000 (CT)
  -6.242648111672788E+05  1.052858803270114E+05  2.399085445691720E+03
   1.440661613131597E-03 -1.067448760443137E-02 -1.420940086898737E-05
   2.111746384510528E+00  6.330856392850241E+05 -3.195872940984194E-03

1 sec later:

2455562.500011574 = A.D. 2011-Jan-01 00:00:01.0000 (CT)
  -6.243886100837820E+05  1.062083890897747E+05  2.400305087938778E+03
   1.425074440471270E-03 -1.068014312423737E-02 -1.402385602727380E-05
   2.112667426049052E+00  6.333617605917784E+05 -3.195890300145339E-03

=cut
