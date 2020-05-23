#!/bin/perl

# creates an ecliptic map (perhaps eventually for leaflet)

# this is a copy of bc-ecliptic-map.pl that works with output from bc-any-dump-2

# TODO: add equinox points, especially, since I'm shifting by a few degrees

require "/usr/local/lib/bclib.pl";

my(%hip);

# NOTE: changing $factor from 1 will break constellatioj lines

$factor = 1;

# 16384 = 1.32 minutes of arc per pixel
# TODO: maybe bump this up (confuses Imagemagick, but since we're leafletting...)

# my($w,$h) = (16384,16384/12*$factor);
# my($w,$h) = (65536,65536/12*$factor);

# my($w,$h) = (65535,65535/12*$factor);

my($w,$h) = (65536*4,65536*4/12*$factor);
# my($w,$h) = (65536*2,65536*2/12*$factor);

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

my(@all) = `bzcat $bclib{githome}/ASTRO/bc-ecl-coords.txt.bz2`;

$eclipcolor = "255,0,255";

# the ecliptic
my($midy) = $h/2;
print "dline 0,$midy,$w,$midy,$eclipcolor\n";

# this lets me control order of rendering
my(@stars,@consts,@names,@planets);

for $i (@all) {

  chomp($i);
  my($eclong,$eclat,$mag,$id,$hip,$name) = split(/\s+/,$i);

  # keep track of HIP#s for constellation lines
  @{$hip{$hip}} = ($eclong,$eclat);

  my($x,$y) = ell2xy($eclong,$eclat);
  my($r) = round(10.5-$mag);
  if ($y<$r || $y>$h-$r || $r <= 0) {next;}

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

print join("\n",@consts),"\n";
print join("\n",@names),"\n";
print join("\n",@stars),"\n";

warn "TESTING";

exit(0);

while (<>) {

  # TODO: new format uses naif id too (so I can determine colors myself?)
  my($id,$jd,$eclong,$eclat) = split(/\s+/,$_);

  # convert eclong/eclat to xy, after degree conversion
  my($x,$y) = ell2xy($eclong,$eclat);

  my($oppcolor) = 0;

  # if first of month, note it
#  $jd=~s/\*\^/e/;
  my(@time) = gmtime($jd);
  # this is actually month - 1
  my($hour,$mday,$mo) = @time[2..4];

  if ($mo%3==0 && $mday==1 && $hour==0) {
    push(@names,strftime("string 255,255,0,$x,$y,tiny,%b %d %Y",@time));
  } elsif ((($mday==1 || $mday==15) && $hour==0) || eof()) {
    push(@names,strftime("string 255,255,0,$x,$y,tiny,%b %d",@time));
  }

#  push(@planets,"fcircle $x,$y,1,$oppcolor,255,$oppcolor");

  if ($hour==0) {
#    push(@planets,"fcircle $x,$y,2,$oppcolor,255,$oppcolor");
    push(@planets,"fcircle $x,$y,2,255,$oppcolor,$oppcolor");
  } else {
#    push(@planets,"setpixel $x,$y,$oppcolor,255,$oppcolor");
    push(@planets,"setpixel $x,$y,255,$oppcolor,$oppcolor");
  }
}

print join("\n",@planets),"\n";

# this subroutine uses globals, not suitable for general use

sub ell2xy {
  my($eclong,$eclat) = @_;
  # the +6 is a test to keep virgo whole
  $eclong = fmodn($eclong+6,360);
  return (round($w*(-$eclong/360+1/2)),round(-$factor*$w*$eclat/360+$h/2));
}
