#!/bin/perl

# Perl script that converts simple FORTRAN to Mathematica, primarily
# so I can use IAU SOFA libs in Mathematica (http://www.iausofa.org/)

# TODO: at the moment, this will NOT convert many things, keep an eye
# on results

require "/usr/local/lib/bclib.pl";

my($all,$fname) = cmdfile();

# remove comments
$all=~s/^\*.*$//mg;
# remove blank lines
$all=~s/\n+/\n/sg;
# fix continuation lines
$all=~s/\n\s*:\s*/ /g;
# remove leading spaces
$all=~s/^\s+//mg;
# lower case (Mathematica reserves upper case names)
$all=lc($all);

my(@formulas);

# parameters
while ($all=~s/^parameter\s*\((.*)\)$//m) {
  my($param) = $1;
  # remove spaces
  $param=~s/\s//g;
  push(@formulas,$param);
}

# regular formulas

while ($all=~s/^(.*?\s*\=\s*.*)$//m) {
  my($form) = $1;
  # remove spaces
  $form=~s/\s//g;
  push(@formulas,$form);
}

# convert formulas

for $i (@formulas) {
  # convert numbers
  $i=~s/(\d+\.?\d*)d(\-?\d+)/Rationalize[$1*10^$2,10^-100]/g;
  print "$i;\n";
}
