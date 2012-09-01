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
# "m/s" => 1,
 "mi" => 1609.344,
 "hr" => 3600,
# "mph" => 1/0.44704,
 "in" => 1/39.3701,
 "year" => 365.2425*86400
);

# the metric prefixes (excluding non 10^-3*n for now)
# doing micro as u, can't type mu (there is no prefix for 1, so using
# | as placeholder)

$size = 10**-24;
for $i (split(//,"yazfpnum|kMGTPY")) {
  $metric{$i} = $size;
  $size*=1000;
}

for $i (split(/\n/,read_file("speeds.txt"))) {
  # skip comments/blanks
  if ($i=~/\#/ || $i=~/^\s*$/) {next;}

  debug("I: $i");
  # separate number from units and desc
  $i=~/^([\d\.]+)(.*?)\s+(.*?)$/;
  # TODO: add "short desc" for bar itself?
  my($speed,$unit,$desc) = ($1,$2,$3);
  $res = convert2($speed,$unit,"m/s");
  debug("I: $desc: $res");
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
  my($temp);

  # redundant code again: mph to mi/hr
  if ($from=~/^mph$/i) {$from="mi/hr";}
  if ($to=~/^mph$/i) {$to="mi/hr";}

  # if the first letter is a metric prefix and the rest is a unit we
  # know about, convert (note: this breaks for deka since its prefix
  # is two letters, but I don't care)
  $from=~/^(.)(.*?)$/;
  my($first,$rest) = ($1,$2);

  if ($metric{$first} && $conversions{$rest}) {
    # remove the prefix
    $from=~s/^.//isg;
    # multiply the quant
    $quant*=$metric{$first};
  }

  $to=~/^(.)(.*?)$/;
  my($first,$rest) = ($1,$2);

  if ($metric{$first} && $conversions{rest}) {
    # remove the prefix
    $to=~s/^.//isg;
    # multiply the quant
    $quant*=$metric{substr($to,0,1)};
  }

  debug("convert2($quant,$from,$to)");

  # if either unit contains "/", parse pieces
  if ($from=~/^(.*?)\/(.*?)$/) {
    my($num,$den) = ($1,$2);
    $quant/=convert2(1,$num,"");
    $quant*=convert2(1,$den,"");
    # new unit is standard unit
    debug("quant now $quant ($from -> stdunit)");
    $from = "";
  }

  # TODO: ack, redundant code!
  if ($to=~/^(.*?)\/(.*?)$/) {
    my($num,$den) = ($1,$2);
    $quant*=convert2(1,$num,"");
    $quant/=convert2(1,$den,"");
    # new unit is standard unit
    debug("quant now $quant ($to -> stdunit)");
    $to = "";
  }

  # convert unit to standard quantity
  if ($conversions{$from}) {
    debug("FROM OK: $conversions{$from}");
    $temp=$quant/$conversions{$from};
  } else {
    return "NULL: can't convert $from to stdunit";
  }

  # and to new unit
  if ($conversions{$to}) {
#    debug("TO OK");
    return $temp*$conversions{$to};
  }

  return "NULL: can't convert $to to stdunit";
}

