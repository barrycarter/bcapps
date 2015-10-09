#!/bin/perl

# creates an ecliptic map (perhaps eventually for leaflet)

# Format for stdin to this program:
# naif-id JD ecliptic-longitude ecliptic-latitude distance(unused) solar_angle

# TODO: add equinox points, especially, since I'm shifting by a few degrees

require "/usr/local/lib/bclib.pl";

my(%hip);
$factor = 1;

# 16384 = 1.32 minutes of arc per pixel
# TODO: maybe bump this up (confuses Imagemagick, but since we're leafletting...)

my($w,$h) = (16384,16384/12*$factor);

# testing
# my($w,$h) = (2048,round(2048/12*$factor));

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

my($all) = read_file("$bclib{githome}/ASTRO/eclipticlong3.txt");

# the ecliptic
my($midy) = $h/2;
print "dline 0,$midy,$w,$midy,255,0,0\n";

# this lets me control order of rendering
my(@stars,@consts,@names,@planets);

for $i (split(/\n/,$all)) {

  chomp($i);
  my($eclong,$eclat,$mag,$hip,$name) = split(/\s+/,$i);

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

  if ($mo%3==0 && $mday==1 && $hour==0) {
    push(@names,strftime("string 255,255,0,$x,$y,tiny,%b %d %Y",@time));
  } elsif (($mday==1 || $mday==15) && $hour==0) {
    push(@names,strftime("string 255,255,0,$x,$y,tiny,%b %d",@time));
  }

#  push(@planets,"fcircle $x,$y,1,$oppcolor,255,$oppcolor");

  if ($hour==0) {
    push(@planets,"fcircle $x,$y,2,$oppcolor,255,$oppcolor");
  } else {
    push(@planets,"setpixel $x,$y,$oppcolor,255,$oppcolor");
  }
}

print join("\n",@planets),"\n";
print join("\n",@consts),"\n";
print join("\n",@names),"\n";
print join("\n",@stars),"\n";

# this subroutine uses globals, not suitable for general use

sub ell2xy {
  my($eclong,$eclat) = @_;
  # the +6 is a test to keep virgo whole
  $eclong = fmodn($eclong+6,360);
  return (round($w*(-$eclong/360+1/2)),round(-$factor*$w*$eclat/360+$h/2));
}
