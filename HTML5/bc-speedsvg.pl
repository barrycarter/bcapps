#!/bin/perl

# before creating a timeline, I'm creating a much simpler "comparison
# of speeds" line

require "/usr/local/lib/bclib.pl";

# TODO: make this nonglobal and way better

# numbers to multiply by to convert units to standard units
%conversions = (
 "m" => 1,
 "s" => 1,
 "in" => 1/39.3701
);

for $i (split(/\n/,read_file("speeds.txt"))) {
  # skip comments/blanks
  if ($i=~/\#/ || $i=~/^\s*$/) {next;}

  debug("I: $i");
  # separate number from units and desc
  $i=~/^([\d\.]+)(.*?)\s+(.*?)$/;
  # TODO: add "short desc" for bar itself?
  my($speed,$unit,$desc) = ($1,$2,$3);

  # if unit contains "/", handle each part separately
  if ($unit=~/^(.*?)\/(.*?)$/) {
    my($num,$den) = ($1,$2);
    # convert top unit to meters
    $num = convert2(1,$num,"m");
    # and bottom to seconds
    $den = convert2(1,$num,"s");
    debug("ND: $num $den");
  } else {
    debug("UNIT: $unit");
  }

  # convert everything to meters/second (for now)
  

}

=item convert2($quant,$from,$to,$type="")

Converts $quant from $from units to $to units, but in a slightly more
intelligent way than convert() [using a fixed intermediate unit]

$type currently unused, but would represent unit type (length, area,
volume, time, etc)

=cut


sub convert2 {
  my($quant,$from,$to,$type) = @_;

  debug("FROM: $from, TO: $to");

  debug($conversions{"in"});

  # convert unit to standard quantity
  if ($conversions{$from}) {
    debug("FROM OK: $conversions{$from}");
    $sfrom=$quant/$conversions{$from};
}

  # and to new unit
  if ($conversions{$to}) {
    debug("TO OK");
    return $sfrom*$conversions{$to};
  }

  warn("Can't handle $from,$to,$type");
  return "NULL";
}

