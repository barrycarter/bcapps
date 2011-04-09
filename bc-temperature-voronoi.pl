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
open(C,">/home/barrycarter/BCINFO/sites/TEST/gmaps.txt");

# <h>unlike a real programming language, JS requires this declaration</h>
print C "var markers = [];\n";

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
    print C "new GLatLng($x, $y),\n";
  }

  debug("POINTS",@points);

      # google maps wants the first point repeated (also, close off coords)
      ($x,$y) = split(/\s+/,$points[0]);
      debug("XY: $x $y *");
      print C "new GLatLng($x, $y)\n];\n";

  # get hue from temp
  # NOTE: this is my own mapping; not NOAA approved!
  $hue=5/6-($temp[$index]/100)*5/6;
  $col=hsv2rgb($hue,1,1);

  # and now the poly itself (and push marker to array for MarkerCluster)
  print C << "MARK";

myPoly = new GPolygon({
 latlngs: myCoords,
 strokeColor: "$col",
 strokeOpacity: 0.8,
 strokeWeight: 1,
 fillColor: "$col",
 fillOpacity: 0.8
});

map.addOverlay(myPoly);

markers.push(new GMarker(
 new GLatLng($lat[$index] , $lon[$index])
));

MARK
;

# TODO: re-add  title:"$temp[$index]F" above

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

# TODO: convert to JPG for those who don't have good SVG viewers
# TODO: create continent specific maps (from same data) like weather.gov
# TODO: color map smoothly, not via polygons
# TODO: ignore older data
# TODO: do this for wind speed, humidity, dew point, etc
