#!/bin/perl

push(@INC,"/usr/local/lib");
require "bclib.pl";

# the KML file created here is visible at
# http://test.barrycarter.info/gmap15.php

# TODO: clickable polygons are REALLY annoying, though probably can't
# fix them scriptwise

# TODO: use real 3D Voronoi, not Mercator approximation

# work in my own temp dir
chdir(tmpdir());
system("pwd");

# pull data from live weather (also available at metar.db.94y.info)
# (my own copy is local); cp avoids db lock
system("cp /sites/DB/metar.db .");
@res = sqlite3hashlist("SELECT time, -strftime('%s', replace(n.time, '-4-','-04-'))+strftime('%s', 'now') AS age, n.code, n.temperature, s.latitude, s.longitude, s.city, s.state, s.country, n.metar FROM nowweather n JOIN stations s ON (n.code=s.metar) WHERE temperature IS NOT NULL AND age>0 AND age<7200", "metar.db");
debug("ER: $SQL_ERROR");

# style testing
$fixedstyle = << "MARK";
<Style id="astyle"> 
<LineStyle> 
<color>7f0000ff</color>
<width>2</width> 
</LineStyle> 
<PolyStyle> 
<color>7f79c63f</color> 
<colorMode>normal</colorMode> 
<fill>1</fill> 
<outline>1</outline> 
</PolyStyle> 
</Style> 
MARK
;

# create file for qvoronoi (header)
open(A,">qhull-file.txt");
print A "2\n"; # dimension
print A $#res+1 . "\n"; # number of points

# create file for qvoronoi (body) and note temp for later use
for $i (@res) {
%hash = %{$i};
($time[$n], $lat[$n], $lon[$n], $temp[$n], $stat[$n], $city[$n], $country[$n], 
 $metar[$n], $state[$n]) = 
($hash{time}, $hash{latitude}, $hash{longitude}, $hash{temperature}*1.8+32, $hash{code},
 $hash{city}, $hash{country}, $hash{metar}, $hash{state});
# skip NZSP Antarctica for now (boo!) 
# TODO: fix
if ($lat[$n]<-85) {next;}

# convert to Mercator for qhull
$mlat = log(tan($PI/4+$lat[$n]/180*$PI/2));
$mlon = $lon[$n]/180*$PI;
print A "$mlat $mlon\n";

$n++;
}

close(A);

debug("FILE:",read_file("qhull-file.txt"));

# run qvoronoi
system("qvoronoi s o < qhull-file.txt > qhull-out.txt");

# @regions includes both polygons (defined as points) and the points themselves
@regions=split(/\n/,suck("qhull-out.txt"));

# first two lines give info
($di) = shift(@regions);
($pts, $regions, $x) = split(/\s+/,shift(@regions));

# write in google maps "format"
# <h>A "fomrat" is an extremely well organized rodent</h>
# below file is currently unused
open(C,">/home/barrycarter/BCINFO/sites/TEST/gmaps.txt");

# and KML
# below file is the one I actually use for gmap15.php
open(B,">/home/barrycarter/BCINFO/sites/TEST/weather.kml");
print B << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
$fixedstyle
MARK
;

# the regions start at $pts+1
for $i ($pts+1..$#regions) {

  # this is the region for which point
  $index = $i-$pts;

  # TODO: ignoring unbounded regions now, but should fix
  if ($regions[$i]=~/ 0( |$)/) {next;}

  # the numbers of the points making up this polygon
  @points=split(/\s+/,$regions[$i]);
  # the first one is dimension (uninteresting)
  shift(@points);

  # map the rest to actual point coords
  map($_=trim($regions[$_]),@points);

  unless (@points) {next;}

  # KML
  print B "<Placemark>\n";
  print B "<gx:balloonVisibility>0</gx:balloonVisibility>\n";
  print B "<styleUrl>#$stat[$index]</styleUrl>\n";
  print B "<title>TITLE</title>\n";
#  print B "<description>$stat[$index] ($city[$index], $state[$index], $country[$index])\n$metar[$index] ($temp[$index]F)</description>\n";
  print B "<description>$stat[$index] ($city[$index], $state[$index], $country[$index]) $temp[$index]F ($time[$index])</description>\n";
  print B "<Polygon><outerBoundaryIs><LinearRing><coordinates>\n";

  # for google maps
  print C "var myCoords = [\n";

  # TODO: handle "180" condition better (polygon crosses +-180E)
  # removed nonworking code I had for this: not right approach

  # do any of the points go outside world boundaries?
  # if so, adjust them down
  for $j (@points) {
    ($x,$y) = split(/\s+/,$j);

    # TODO: really need to figure out how to handle this better
    if ($y<-1*$PI) {$y=-1*$PI;}
    if ($y>$PI) {$y=$PI;}

    # convert back from mercator
    $y = $y/$PI*180;

    $x = atan(sinh($x))/$PI*180;
    $j = "$x $y";
    debug("LL: $x,$y");
    # for google maps
    print C "new google.maps.LatLng($x, $y),\n";
    # KML
    print B "$y,$x\n";
  }

  debug("AFTER: $lat[$index],$lon[$index] ->",@points);

  # google maps wants the first point repeated (also, close off coords)
  ($x,$y) = split(/\s+/,$points[0]);
  debug("XY: $x $y *");
  print C "new google.maps.LatLng($x, $y)\n];\n";
  # as does KML?
  print B "$y,$x\n";

  # get hue from temp
  # NOTE: this is my own mapping; not NOAA approved!
  debug("INDEX: $index");
  $hue=5/6-($temp[$index]/100)*5/6;

  # below: testing for limited number of colors
#  $hue = floor($hue*4+.5)/4;

  $col=hsv2rgb($hue,1,1);

# and now the poly itself (and push marker to array for MarkerCluster)
print C << "MARK";

myPoly = new google.maps.Polygon({
 paths: myCoords,
 strokeColor: "#000000",
 strokeOpacity: 0.8,
 strokeWeight: .01,
 fillColor: "$col",
 fillOpacity: 0.4
});

myPoly.setMap(map);

MARK
;

# KML
print B "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>\n";
$kmlcol = hsv2rgb($hue,1,1,"kml=1&opacity=80");

print B << "MARK";

<Style id="$stat[$index]">
<PolyStyle><color>$kmlcol</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>

MARK
;

=item comment

var marker = new google.maps.Marker({
 position: new google.maps.LatLng($lat[$index], $lon[$index]), 
 map: map, 
 title:"$stat[$index] ($temp[$index], $hue, $index)"
});

=cut

# TODO: re-add title:"$temp[$index]F" above

# changing spaces to commas
map(s/ /,/g,@points);

# convert array to string
$pstr = join(" ",@points);

debug("$regions[$i] -> $pstr");

# TODO: add semi-transparent country/state borders
# TODO: get rid of borders on these polygons
# print B "<polygon points='$pstr' style='fill:$col' />\n";

# TODO: commented out text as it looks bizarre on firefox/opera
# TODO: so need to fix that
# print B "<text x='$lat[$index]' y='$lon[$index]' style='font-family:Verdana;font-size:0.1'>$temp[$index]</text>\n";

}

print B "</Document></kml>\n";

# print B "</g></svg>\n";
# close(B);

# TODO: convert to JPG for those who don't have good SVG viewers
# TODO: create continent specific maps (from same data) like weather.gov
# TODO: color map smoothly, not via polygons
# TODO: ignore older data
# TODO: do this for wind speed, humidity, dew point, etc
