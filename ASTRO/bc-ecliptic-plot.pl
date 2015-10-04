#!/bin/perl

# Planetary positions as ecliptical longitudes

require "/usr/local/lib/bclib.pl";

# TODO: add moon

# not sure if I'm going to use Uranus, but computing it just in case

# format (from playground18.m) is (AU-distance,degree-at-epoch,degrees
# per 36525 days = NASA century, rgb color)

# TODO: this has the winter solstice at 90 degrees (sun-earth), is that bad?

@planets = (
[0.38709843,252.25166724,149472.67486623,255,128,128],
[0.72332102,181.97970850,58517.81560260,0,255,0],
[1.00000018,100.46691572,35999.37306329,0,0,255],
[1.52371243,-4.56813164,19140.29934243,255,0,0],
[5.20248019,34.33479152,3034.90371757,0,255,255],
[9.54149883,50.07571329,1222.11494724,255,255,0]
);

# commenting out uranus for now
# [19.18797948,314.20276625,428.49512595,0,0,255]);

($xwid,$ywid) = (800,800);

$xwid2 = $xwid/2;
$ywid2 = $ywid/2;

# halfwidth of image in AU (lower dimension)
my($range) = $planets[5][0];

# for fly
print << "MARK";
new
size $xwid,$ywid
setpixel 0,0,0,0,0
MARK
;

@pos = positions(96);

# these must be drawn first, otherwise fcircle confuses fly
for $i (@planets) {
  my($x,$y) = au2pixels(@{shift(@pos)});
  my($rgb) = join(",",@$i[3..5]);
  print "fcircle $x,$y,6,$rgb\n";
}

# draw planet orbits
for $i (@planets) {
  my($au) = round(@$i[0]*$xwid/$range);
  my($rgb) = join(",",@$i[3..5]);
  print "circle $xwid2,$ywid2,$au,$rgb\n";
}

# convert pure xy (AU) to pixels

sub au2pixels {
  my($x,$y) = @_;
  return (round($xwid/2+($x/$range)*$xwid/2),round($ywid/2+($y/$range)*$ywid/2));
}

# planets xy position d days from J2000.0

sub positions {
  my($d) = @_;
  my(@ret);

  for $i (@planets) {
    my($au,$deg,$motion) = @$i;
    my($rad) = fmod($motion/36525*$d+$deg,360)*$DEGRAD;
    my($x,$y) = ($au*cos($rad),$au*sin($rad));
    push(@ret, [$x,$y]);
  }

  return(@ret);
}

