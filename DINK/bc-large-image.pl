#!/bin/perl

# a 19200x6400 map of ABQ for dink testing

# some of this code comes from ../OSM/bc-parse-addr.pl w/ mods

# TODO: this covers too wide an area

# Extents: 34.8695709310438 to 35.2185421030882
# Lon: -107.190882540743 to -106.149658771479

# True city limits (28 Jun 2015):
# -106.8727864516886 to -106.4711832053026
# 34.9471161943005 to 35.21795333996647

require "/usr/local/lib/bclib.pl";

print << "MARK";
new
size 19200,6400
setpixel 0,0,255,255,255
MARK
;

my($xmin,$xmax,$ymin,$ymax) = 
#  (-107.190882540743,-106.149658771479, 34.8695709310438, 35.2185421030882);
(-106.8727864516886,-106.4711832053026,34.9471161943005,35.21795333996647);

open(A,"bzcat $bclib{githome}/db/abqaddr.bz2|");

while (<A>) {
  ($lot, $block, $subdivision, $num, $sname, $stype, $sdir, $apt, $pin,
$latlon) = split(/\|/, $_);

  unless ($latlon=~/^POINT\((.*?)\s+(.*?)\)$/) {next;}
  ($lon, $lat) = ($1, $2);

  # TODO: filter addresses better here, eg 99999 is not valid
  my($saddr) = "$num $sname $stype $sdir";
  if ($apt) {$saddr = "$saddr #$apt";}
  # strip extra spaces
  $saddr=~s/\s+/ /isg;
  $saddr=trim($saddr);
  # ignore "0" address (or any pure digit addr) and 99999 garbage
  if ($saddr=~/^\d*$/||$saddr=~/99999/) {next;}

  # TODO: this is just to avoid too much printing
#  if (rand()<.9) {next;}

  my($x) = round(($lon-$xmin)/($xmax-$xmin)*19200);
  my($y) = round((1-($lat-$ymin)/($ymax-$ymin))*6400);

  # TODO: this map is stretched, need to fix that
  print "string 0,0,0,$x,$y,tiny,$saddr\n";
#  print "setpixel $x,$y,255,0,0\n";
#  print "fcircle $x,$y,2,255,0,0\n";
}

die "TESTING";


# uses fly to create a "random" large image that should not be viewed
# directly, but will be cut up into 600x400 dink tilescreens

require "/usr/local/lib/bclib.pl";

for $i (1..100000) {
  my($x) = int(rand()*19200);
  my($y) = int(rand()*9600);
  print "string 0,0,0,$x,$y,tiny,$x $y\n";
}


