#!/bin/perl

# Converts VSOP87 barycentric coordinates to something Mathematica can
# use, just for fun (since DE430 is more accurate)

# NOTE: T is the number of Julian millenia since J2000.0 (JDE-2451545)/365250


require "/usr/local/lib/bclib.pl";

# "E" for barycentric
$all = read_file("/home/barrycarter/SPICE/KERNELS/VSOP87E.ven");
my(@coeffs);

for $i (split(/\n/,$all)) {
  # does this line have a coefficient (if so, record it and move on)
  if ($i=~/\*T\*\*(\d+)/) {$coeff = $1; next;}

  # only the last three fields matter
  # TODO: figure out what the other fields mean
  # Thanks to: http://www.caglow.com/info/compute/vsop87
  my(@fields) = split(/\s+/, $i);
  my($a, $b, $c) = @fields[-3..-1];
  # TODO: rationalize
  # push to appropriate array
  push(@{$coeffs[$coeff]}, "$a*Cos[$b + $c*t]");
}

my(@sum);

for $i (0..$#coeffs) {
  my($terms) = join("+\n", @{$coeffs[$i]});
  push(@sum, "($terms)*t^$i");
}

my($final) = "f[t_] = ".join("+\n", @sum).";";

write_file($final, "/tmp/math1105.m");
