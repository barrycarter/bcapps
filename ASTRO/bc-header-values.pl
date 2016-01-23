#!/bin/perl

# Creates Mathematica code to solve differential equations for
# planetary motion (as NASA does)

require "/usr/local/lib/bclib.pl";

$all = read_file("$bclib{githome}/ASTRO/header.430_572");

# cheating slightly here
$all=~s/(DENUM.*?)GROUP/GROUP/s;
my($names) = lc($1);
my(@names) = split(/\s+/, $names);

# the values
$all=~s/1041.*?(0\..*?)GROUP//s;
my($vals) = $1;
my(@vals) = split(/\s+/, $vals);
map(s/D/*10^/g, @vals);

for $i (0..$#names) {print "$names[$i]=$vals[$i];\n";}

# now, lets setup the DFQs (all units are in AU and days, per NASA)

# initial positions/velocity at epoch

my(@init);

# for $i (1,2,4..9,"m","s","b") {
for $i (1) {
  warn "TESTING";
  push(@init,"planet[$i][0] == {x$i, y$i, z$i}");
  push(@init,"planet[$i]'[0] == {xd$i, yd$i, zd$i}");

  # TODO: THIS IS JUST FOR TESTING
  push(@init,"planet[$i]''[t] == {0,0,0}");

}

print "posvel = {\n";
print join(",\n", @init);
print "};\n";





