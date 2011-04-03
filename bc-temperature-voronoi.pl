#!/bin/perl

push(@INC,"/usr/local/lib");
require "bclib.pl";

# read current temps
# TODO: turn this into live command instead of a static file
@temps=split(/\n/,suck("sample-data/current-temps.txt"));

# create file for qvoronoi (header)
open(A,">/tmp/qhull-file.txt");
print A "2\n"; # dimension
print A $#temps+1 . "\n"; # number of points

# create file for qvoronoi (body) and note temp for later use
for $i (0..$#temps) {
  ($lat[$i], $lon[$i], $temp[$i]) = split(/\s+/,$temps[$i]);
  print A "$lat[$i] $lon[$i]\n";
}

close(A);

# run qvoronoi
system("qvoronoi s o < /tmp/qhull-file.txt > /tmp/qhull-out.txt");

# @regions includes both polygons (defined as points) and the points themselves
@regions=split(/\n/,suck("/tmp/qhull-out.txt"));

# first two lines give info
($di) = shift(@regions);
($pts, $regions, $x) = split(/\s+/,shift(@regions));

# SVG starts with this
# NOTE: if you do svg width="100%", imagemagick chokes!
# TODO: the dimensions have to match my SVG coords, which isn't great
$svgpre = << "MARK";
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="1080px" height="720px" version="1.1"
xmlns="http://www.w3.org/2000/svg">
<g transform="scale(3,3) rotate(-90) translate(-90,180)">
MARK
;

# write to file
open(B,">/tmp/tempmap.svg");

# write in google maps "format"
# <h>A "fomrat" is an extremely well organized rodent</h>
open(C,">/tmp/gmaps.txt");

# for now, print the header, nothing more
print B $svgpre;

# the regions start at $pts+1
for $i ($pts+1..$#regions) {

  # TODO: ignoring unbounded regions now, but should fix
  if ($regions[$i]=~/ 0( |$)/) {next;}
      
  # the numbers of the points making up this polygon
  @points=split(/\s+/,$regions[$i]);
  # the first one is dimension (uninteresting)
  shift(@points);

  # map the rest to actual point coords
   map($_=trim($regions[$_]),@points);

   unless (@points) {next;}

  # for google maps
  print C "var myCoords = [\n";

  # do any of the points go outside world boundaries?
  # if so, adjust them down
  for $j (@points) {
    ($x,$y) = split(/\s+/,$j);
    $y=max(min($y,180),-180);
    $x=max(min($x,90),-90);
    $j="$x $y";
    # for google maps
    print C "new google.maps.LatLng($x, $y),\n";
  }

  debug("POINTS",@points);

      # google maps wants the first point repeated (also, close off coords)
      ($x,$y) = split(/\s+/,$points[0]);
      debug("XY: $x $y *");
      print C "new google.maps.LatLng($x, $y)\n];\n";

  # get hue from temp
  # NOTE: this is my own mapping; not NOAA approved!
  $hue=5/6-($temp[$index]/100)*5/6;
  $col=hsv2rgb($hue,1,1);

  # and now the poly itself (and a marker)
  print C << "MARK";

myPoly = new google.maps.Polygon({
 paths: myCoords,
 strokeColor: "$col",
 strokeOpacity: 0.8,
 strokeWeight: 1,
 fillColor: "$col",
 fillOpacity: 0.8
});

myPoly.setMap(map);

new google.maps.Marker({
 position: new google.maps.LatLng($lat[$index],$lon[$index]),
 map: map, 
 title:"$temp[$index]F"
});

MARK
;

  # changing spaces to commas
  map(s/ /,/g,@points);

  # this $i corresponds to this entry in points file
  $index = $i-$pts;

  # convert array to string
  $pstr = join(" ",@points);

  debug("$regions[$i] -> $pstr");

  # TODO: this map is hideous -- use mercator or project to sphere or something
  # TODO: add semi-transparent country/state borders
  # TODO: get rid of borders on these polygons
  print B "<polygon points='$pstr' style='fill:$col' />\n";

  # TODO: commented out text as it looks bizarre on firefox/opera
  # TODO: so need to fix that
#  print B "<text x='$lat[$index]' y='$lon[$index]' style='font-family:Verdana;font-size:0.1'>$temp[$index]</text>\n";

}

print B "</g></svg>\n";
close(B);

# Converts hue to RGB, my own hack, not necessarily official
sub hsv2rgb {
  my($hue,$sat,$val) = @_;
  $hue=$hue-floor($hue);
  $hv=floor($hue*6);

  # can't get given/when to work, so...
  if ($hv==0) {$r=1; $g=6*$hue; $b=0;} elsif
    ($hv==1) {$r=2-6*$hue; $g=1; $b=0;} elsif
    ($hv==2) {$r=0; $g=1; $b=6*$hue-2;} elsif
    ($hv==3) {$r=0; $g=4-6*$hue; $b=1;} elsif
    ($hv==4) {$r=6*$hue-4; $g=0; $b=1;} elsif
    ($hv==5) {$r=1; $g=0; $b=6-6*$hue;} else
      {$r=0; $g=0; $b=0;}
  $r=min($r+1-$sat,1)*$val;
  $g=min($g+1-$sat,1)*$val;
  $b=min($b+1-$sat,1)*$val;
  return sprintf("#%0.2x%0.2x%0.2x",$r*255,$g*255,$b*255);
}

# TODO: convert to JPG for those who don't have good SVG viewers
# TODO: create continent specific maps (from same data) like weather.gov
# TODO: color map smoothly, not via polygons
# TODO: ignore older data
# TODO: do this for wind speed, humidity, dew point, etc
