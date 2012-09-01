#!/bin/perl

# before creating a timeline, Im creating a much simpler "comparison
# of speeds" line

require "/usr/local/lib/bclib.pl";

# TODO: make this nonglobal and way better

# numbers to multiply by to convert units to standard units
# TODO: not convinced that allow m/s directly is good
%conversions = (
 "" => 1,
 "m" => 1,
 "s" => 1,
 "mi" => 1609.344,
 "hr" => 3600,
 "in" => 1/39.3701,
 "year" => 365.2425*86400,
 "c" => 1/299792458
);

# the metric prefixes (excluding non 10^-3*n for now)
# doing micro as u, can't type mu (there is no prefix for 1, so using
# | as placeholder)

$size = 10**-24;
for $i (split(//,"yazfpnum|kMGTPY")) {
  $metric{$i} = $size;
  $size*=1000;
}

# debug(%metric);

# convert2("20.4774871938", "km/hr");

# die "TESTING";

for $i (split(/\n/,read_file("speeds.txt"))) {
  # skip comments/blanks
  if ($i=~/\#/ || $i=~/^\s*$/) {next;}

  debug("I: $i");
  # separate number from units and desc
  $i=~/^([\d\.]*)(.*?)\s+(.*?)$/;
  # TODO: add "short desc" for bar itself?
  my($speed,$unit,$desc) = ($1,$2,$3);
  # for things like "c"
  unless ($speed) {$speed=1;}
  $res = convert2($speed,$unit);
  debug("I: $desc: $res");
  # store
  $desc{$res} = $desc;
}

# sort, so we can make rectangles the right width
@speeds = sort {$a <=> $b} keys %desc;

# and create SVG (at last!)

for $i (@speeds) {
  debug("$i: $desc{$i}");
}

=item convert2($quant,$from,$to="",$type="")

Converts $quant from $from units to $to units, but in a slightly more
intelligent way than convert() [using a fixed intermediate unit]

if $from/$to is blank, just convert to/from standard unit

$type currently unused, but would represent unit type (length, area,
volume, time, etc)

TODO: someones proably created a module for this?
TODO: add metric prefixes
TODO: allow things like (m/s)/s (or too complex?)
TODO: serious error checking

=cut

sub convert2 {
  my($quant,$from,$to,$type) = @_;
  debug("convert2($quant,$from,$to,$type)");
  my(@u) = ($from,$to);
  my($temp);

  # both both unit types...
  for $i (@u) {
    # convert mph to mi/hr
    $i=~s/^mph$/mi\/hr/;

  # if the first letter is a metric prefix and the rest is a unit we
  # know about, convert (note: this breaks for deka since its prefix
  # is two letters, but I don't care)
    $i=~/^(.)(.*?)$/;
    my($first,$rest) = ($1,$2);
#    debug("FIRST: $first, REST: $rest");

    if ($metric{$first} && $i && $rest && $conversions{$rest}) {
      debug("*$i* being metricized");
      debug("FIRST: *$first* -> $metric{$first}");
      debug("REST: *$rest* -> $conversions{$rest}");
      # remove the prefix
      $i=~s/^.//isg;
      # multiply the quant
      $quant/=$metric{$first};
      debug("quant now $quant (metric: $first)");
  }

  # if either unit contains "/", parse pieces
    if ($i=~/^(.*?)\/(.*?)$/) {
      my($num,$den) = ($1,$2);
      $quant/=convert2(1,$num,"");
      $quant*=convert2(1,$den,"");
      # new unit is standard unit
      debug("quant now $quant ($i -> stdunit)");
      $i = "";
    }
  }

  # code below isn't redundant (* vs /) but could still be combined
  
  # convert unit to standard quantity
  if ($conversions{$u[0]}) {
    debug("FROM OK: $conversions{$u[0]}");
    $temp=$quant/$conversions{$u[0]};
  } else {
    return "NULL: can't convert $u[0] to stdunit";
  }

  # and to new unit
  if ($conversions{$u[1]}) {
#    debug("TO OK");
    return $temp*$conversions{$u[1]};
  }

  return "NULL: can't convert $to to stdunit";
}

