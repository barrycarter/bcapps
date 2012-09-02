#!/bin/perl

# before creating a timeline, Im creating a much simpler "comparison
# of speeds" line

# -nolog: use real line, not log

# --noscale: don't scale text in x direction (useful when using xy zoom mode of svgtry.html)

# TODO: this breaks if two things have identical speeds

require "/usr/local/lib/bclib.pl";

# SVG header
print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" id="svg" 
 width="1024px" height="600px" viewbox="-512 -300 1024 600">
 <g id="g">
MARK
;

# TODO: make this nonglobal and way better

# numbers to multiply by to convert units to standard units
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

  # TODO: below is cheating, since this code should be indep of this prg
  $desc{$size}="1 ${i}m/s";

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

  if ($desc{$res}) {
    warn "Speed: $res already belongs to $desc{$res}";
    next;
  }

  # store
  $desc{$res} = $desc;
}

# sort, so we can make rectangles the right width
@speeds = sort {$a <=> $b} keys %desc;

# logify
for $i (0..$#speeds) {
  if ($globopts{nolog}) {
    $logspeed[$i] = $speeds[$i];
  } else {
    $logspeed[$i]=log($speeds[$i]);
  }
}

@trueplace = place_items(\@logspeed,0.25);

# and create SVG (at last!)

for $i (0..$#speeds) {
  debug("($logspeed[$i]) $speeds[$i]: $desc{$speeds[$i]}");

  # width of rectangle is half min distance to 2 neighbors
  # special case for first/last elt (but not needed for last!)
  if ($i==0) {
    $width = $logspeed[1]-$logspeed[0];
  } elsif ($i==$#speeds) {
    $width = $logspeed[$i]-$logspeed[$i-1];
  } else {
    $width = min($logspeed[$i]-$logspeed[$i-1],$logspeed[$i+1]-$logspeed[$i]);
  }

#  $width/=2;

  # left edge is thus x-$width/2
  $width=.05;
  $x = $logspeed[$i]-$width/2;

  # random colors (for now)
  $color = hsv2rgb(rand(),1,1);
  debug("COLOR: $color");

  # blue=slow (hue=.875), red=fast (hue=.125)
  $hue = ($logspeed[$i]-$logspeed[0])/($logspeed[$#speeds]-$logspeed[$0]);
  $hue = .625 - $hue*.625;
#  $color = hsv2rgb($hue,1,1);

  debug("CENTER: $x, WIDTH: $width, HUE: $hue");  

  $fontsize = $width;

  print qq%<rect title="$desc{$speeds[$i]} ($speeds[$i] m/s)" x="$x" y="-10" height="20" width="$width" fill="$color" />\n%;

#  $textx = $logspeed[$i];
  $textx = $trueplace[$i];
  $translate = -$textx;
  $fontsize=12;
  $scale = $width/15;
  $scale = .02;

  if ($globopts{noscale}) {
    $fontsize=1;
    $scale=1;
  }

  print qq%<text title="$desc{$speeds[$i]} ($speeds[$i] m/s)" x="$textx" y="0" fill="black" style="font-size:$fontsize" transform="translate($textx,-20) scale($scale,1) rotate(-90,0,0) translate($translate,0)">$desc{$speeds[$i]}</text>\n%;

  print qq%<line x1="$x" y1="-10" x2="$textx" y2="-20" style="stroke:rgb(0,0,0);stroke-width:0.02;" />\n%;

}

# and SVG tail
print "</g></svg>\n";

print read_file("svgtry.html");

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

=item place_items(\@l, $dist)

Given a list @l of numbers, return a list that keeps numbers as close
to original but at least $dist apart from each other

=cut

sub place_items {
  my($lref,$dist) = @_;
  my(@l) = @{$lref};
  my($minval)=$l[0];
  my(@ret);

  # TODO: this is a very simplistic approach that can be improved by
  # starting with the median element and working outwards

  @l = sort {$a <=> $b} @l;

  for $i (@l) {
    # give element lowest position above what it wants above minval
    my($val) = max($minval,$i);
    push(@ret,$val);
    $minval = $val+$dist;
  }

  return @ret;
}
