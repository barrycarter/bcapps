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

  my($x,$y) = ell2xy($eclong,$eclat);
  my($r) = round(6-$mag);
  if ($y<0 || $y>$h) {next;}

  # the ecliptic
  my($midy) = $h/2;
  print "dline 0,$midy,$w,$midy,255,0,0\n";

  # testing limit
  if ($mag<=3.5) {
    print "string 0,0,255,$x,$y,tiny,$name\n";
  }

  print "fcircle $x,$y,$r,255,255,255\n";
}

# using 2015 venus as example

# TODO: draw venus/planets later so they don't cover up star

# $all = read_file("/tmp/ven.txt");

# while ($all=~s/\{+(.*?),\s*\{(.*?),\s*(.*?),\s*(.*?)\},\s*(.*?)\}+//) {
#  my($jd,$eclong,$eclat,$dist,$sangle) = ($1,$2,$3,$4,$5,$6);

# Using different format for now

while (<>) {

  my($jd,$eclong,$eclat,$sangle) = split(/\s+/,$_);

  debug("JD: $jd");

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
  my($mday,$mo) = ($time[3],$time[4]);

  my($print);

  if ($mo%3==0 && $mday==1) {
    print strftime("string 255,255,0,$x,$y,tiny,%b %d %Y\n",@time);
  } elsif ($mday==1 || $mday==15) {
    print strftime("string 255,255,0,$x,$y,tiny,%b %d\n",@time);
  }

  print "fcircle $x,$y,5,$oppcolor,255,$oppcolor\n";

}

# this subroutine uses globals, not suitable for general use

sub ell2xy {
  my($eclong,$eclat) = @_;
  $eclong = fmodn($eclong,360);
  debug("GOT: $eclong/$eclat");
  return ($w*(-$eclong/360+1/2),-$factor*$w*$eclat/360+$h/2);
}
