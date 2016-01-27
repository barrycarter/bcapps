#!/bin/perl

# Creates Mathematica code to solve differential equations for
# planetary motion (as NASA does)

require "/usr/local/lib/bclib.pl";

$all = read_file("$bclib{githome}/ASTRO/header.431_572");

# cheating slightly here
$all=~s/(DENUM.*?)GROUP/GROUP/s;
my($names) = lc($1);
my(@names) = split(/\s+/, $names);

# change GMB to GM3 and GMS to GM0
map(s/^(gm|[xyz]d?)b$/${1}3/, @names);
map(s/^(gm|[xyz]d?)s$/${1}0/, @names);

# the values
$all=~s/1041.*?(0\..*?)GROUP//s;
my($vals) = $1;
my(@vals) = split(/\s+/, $vals);
map(s/D/*10^/g, @vals);

for $i (0..$#names) {print "$names[$i]=$vals[$i];\n";}

# TODO: this computes EMB, but not E or M directly
my(@planets) = (0..9);

# now, lets setup the DFQs (all units are in AU and days, per NASA)???

# initial positions/velocity at epoch

my(@init);
for $i (@planets) {
  push(@init,"planet[$i][0] == {x$i, y$i, z$i}");
  push(@init,"planet[$i]'[0] == {xd$i, yd$i, zd$i}");
}

print "posvel = {\n";
print join(",\n", @init);
print "};\n";

# now, their gravitational influence on each other

my(@all) = ();
for $i (@planets) {
  my(@accel) = ();
  for $j (@planets) {
    if ($i eq $j) {next;}

    push(@accel, "gm$j*(planet[$i][t]-planet[$j][t])/
           Norm[planet[$i][t]-planet[$j][t]]^3");
  }
  push(@all, "planet[$i]''[t] == -Total[{".join(",\n",@accel)."}]");
}

print "accels = {\n";
print join(",\n", @all);
print "};\n";



