#!/bin/perl

# creates an ecliptic map (perhaps eventually for leaflet)

# Format for stdin to this program:
# naif-id JD ra dec distance(unused) solar_angle

# TODO: add equinox points, especially, since I'm shifting by a few degrees

require "/usr/local/lib/bclib.pl";

my(%hip);
$factor = 1;

# 16384 = 1.32 minutes of arc per pixel
# TODO: maybe bump this up (confuses Imagemagick, but since we're leafletting...)

# my($w,$h) = (16384,16384/12*$factor);

my($w,$h) = (4096,4096/6*$factor);

# my($w,$h) = (2048,2048/6*$factor);

# testing
# my($w,$h) = (2048,round(2048/12*$factor));
# my($w,$h) = (4096,round(4096/12*$factor));

# setting a blue pixel here forces the color to be available later
# (not sure why I have to surround it with black pixels on each side,
# but that does work)

print << "MARK";
new
size $w,$h
setpixel 0,0,0,0,0
setpixel 0,0,0,0,255
setpixel 0,0,0,0,0
MARK
;

# hack show the ecliptic

for ($i=0; $i<=2*$PI; $i+=.001) {
  my($r1, $r2) = ecl2equ($i,0);
  my($x, $y) = ell2xy($r1*$RADDEG, $r2*$RADDEG);
  print "setpixel $x,$y,0,255,0\n";
}

my($all) = read_file("$bclib{githome}/ASTRO/equatorcoords.txt");

$eclipcolor = "255,0,255";

# the equator
my($midy) = $h/2;
print "line 0,$midy,$w,$midy,$eclipcolor\n";

# this lets me control order of rendering
my(@stars,@consts,@names,@planets);

for $i (split(/\n/,$all)) {

  chomp($i);
  my($eclong,$eclat,$mag,$hip,$name) = split(/\s+/,$i);

  if ($mag>5.5) {next;}

  # keep track of HIP#s for constellation lines
  @{$hip{$hip}} = ($eclong,$eclat);

  my($x,$y) = ell2xy($eclong,$eclat);
  my($r) = round(7-$mag);
  if ($y<$r || $y>$h-$r) {next;}

  push(@stars,"fcircle $x,$y,$r,255,255,255");

  if (length($name)) {
    push(@names,join(",","string 128,128,128",$x+5,$y,"tiny,$name"));
  }
}

for $i (split(/\n/,read_file("$bclib{githome}/ASTRO/constellationship.fab"))) {

  # format is name, number of pairs, followed by HIP pairs
  chomp($i);
  my(@line) = split(/\s+/, $i);

  for ($j=2; $j<=$#line; $j+=2) {

    # ignore if I have no data for either (possibly because one not near eclip)
    my(@s1) = @{$hip{$line[$j]}};
    my(@s2) = @{$hip{$line[$j+1]}};
    unless (@s1 && @s2) {next;}

    # convert to pixels
    @s1 = ell2xy(@s1);
    @s2 = ell2xy(@s2);

    # ignore ones that cross the 12h line
    if (abs($s1[0]-$s2[0])>$w/2) {next;}

    # draw line
    push(@consts,"line ".join(",",@s1,@s2).",0,0,255");
  }
}

while (<>) {

  # TODO: new format uses naif id too (so I can determine colors myself?)
  my($id,$jd,$eclong,$eclat,$sangle) = split(/\s+/,$_);

  # convert eclong/eclat to xy, after degree conversion
  my($x,$y) = ell2xy($eclong*$RADDEG,$eclat*$RADDEG);

  # distance from sun in degrees; if closer than 18, fade color to white
  $sangle*=$RADDEG;
  my($oppcolor) = 0;
  if ($sangle<18) {$oppcolor = round(255-$sangle/18*255);}

  # if first of month, note it
  $jd=~s/\*\^/e/;
  my(@time) = gmtime(jd2unix($jd,"jd2unix"));
  # this is actually month - 1
  my($hour,$mday,$mo) = @time[2..4];

  my($xp, $yp) = ($x+5, $y+2);

  if ($mo%3==0 && $mday==1 && $hour==0) {
    push(@names,strftime("string 255,255,0,$x,$y,tiny,%b %d %Y",@time));
#  } elsif ((($mday==1 || $mday==15) && $hour==0) || eof()) {
  } elsif ($hour==0) {
    push(@names,strftime("string 255,255,0,$xp,$yp,tiny,%b %d",@time));
  }

#  push(@planets,"fcircle $x,$y,1,$oppcolor,255,$oppcolor");

  if ($hour==0) {
#    push(@planets,"fcircle $x,$y,2,$oppcolor,255,$oppcolor");
#    push(@planets,"fcircle $x,$y,2,255,$oppcolor,$oppcolor");
    push(@planets,"fcircle $x,$y,10,255,255,0");
  } else {
#    push(@planets,"setpixel $x,$y,$oppcolor,255,$oppcolor");
#    push(@planets,"setpixel $x,$y,255,$oppcolor,$oppcolor");
    push(@planets,"setpixel $x,$y,255,255,0");
  }
}

print join("\n",@planets),"\n";
print join("\n",@consts),"\n";
print join("\n",@names),"\n";
print join("\n",@stars),"\n";

# this subroutine uses globals, not suitable for general use

sub ell2xy {
  my($eclong,$eclat) = @_;
  # the +6 was a test to keep virgo whole
  $eclong = fmodn($eclong+0,360);
  return (round($w*(-$eclong/360+1/2)),round(-$factor*$w*$eclat/360+$h/2));
}

=item ecl2equ($ra,$dec)

TODO: document this, stole it from bc-hyg2db.pl trivially

DOES THE OPPOSITE OF:
Given right ascension and declination (radians), return ecliptic
coordinates (in radians), assuming J2000

=cut

sub ecl2equ {
  my($ra,$dec) = @_;

  # TODO: recomputing this each time is ugly
  my(@mat) = rotrad(-23.443683*$DEGRAD,"x");

  # to xyz
  my($x,$y,$z) = sph2xyz($ra,$dec,1);

  # matrix multiplication
  # TODO: this is ugly, make matrix dot vector easier?
  my(@xyz2) = matrixmult(\@mat,[[$x],[$y],[$z]]);

  return xyz2sph($xyz2[0][0],$xyz2[1][0],$xyz2[2][0]);
}


