#!/bin/perl

# creates an ecliptic map (perhaps eventually for leaflet)

require "/usr/local/lib/bclib.pl";

$factor = 3;
my($w,$h) = (3600,225*$factor);

print "new\nsize $w,$h\nsetpixel 0,0,0,0,0\n";

my($all) = read_file("$bclib{githome}/ASTRO/eclipticlong.txt");

while ($all=~s/\{+(.*?),\s*\{(.*?)\,\s*(.*?)\},\s*(.*?)\}//) {
  my($name,$eclong,$eclat,$mag) = ($1,$2,$3,$4);
  $name=~s/\"//g;

  # exclude too far
#  if (abs($eclat)>360/64) {next;}

  my($x) = $w*(-$eclong/360+1/2);
  # yes, below is really $w, not $h, for rectangularity
  my($y) = -$factor*$w*$eclat/360+$h/2;
#  my($y) = round(113-($eclat/(360/64)*113/2+113/2));
  debug("$eclong/$eclat -> $x,$y");
  my($r) = round(6-$mag);

  if ($y<0 || $y>$h) {next;}

  # fly oddness
#  if ($y+$r > 113) {next;}

  # the ecliptic
  my($midy) = $h/2;
  print "dline 0,$midy,$w,$midy,255,0,0\n";

  # testing limit
  if ($mag<=3.5) {
    print "string 0,0,255,$x,$y,tiny,$name\n";
  }

  print "fcircle $x,$y,$r,255,255,255\n";

#  debug("GOT: $name/$eclong/$eclat/$mag");
}
