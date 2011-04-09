#!/bin/perl

push(@INC,"/usr/local/lib");
require "bclib.pl";

# work in my own temp dir
chdir(tmpdir());

# pull data from live weather (also available at metar.db.94y.info)
# (my own copy is local); cp avoids db lock
system("cp /tmp/metar-live.db .");
@res = sqlite3hashlist("SELECT -strftime('%s', replace(n.time, '-4-','-04-'))+strftime('%s', 'now') AS age, n.code, n.temperature, s.latitude, s.longitude FROM nowweather n JOIN stations s ON (n.code=s.metar) WHERE age>0 AND age<3600", "metar-live.db");

# create file for qvoronoi (header)
open(A,">/tmp/qhull-file.txt");
print A "2\n"; # dimension
print A $#res+1 . "\n"; # number of points

# create file for qvoronoi (body) and note temp for later use
for $i (@res) {
  %hash = %{$i};
  ($lat[$n], $lon[$n], $temp[$n], $stat[$n]) = 
    ($hash{latitude}, $hash{longitude}, $hash{temperature}*1.8+32, $hash{code});
  debug("CODE: $stat[$n] -> $temp[$n]");
  # convert to Mercator for qhull
  $mlat = log(tan($PI/4+$lat[$n]/180*$PI/2));
  $mlon = $lon[$n]/180*$PI;
  print A "$mlat $mlon\n";

  $n++;
}

# run qvoronoi
system("qvoronoi s o < /tmp/qhull-file.txt > /tmp/qhull-out.txt");

# @regions includes both polygons (defined as points) and the points themselves
@regions=split(/\n/,suck("/tmp/qhull-out.txt"));

# first two lines give info
($di) = shift(@regions);
($pts, $regions, $x) = split(/\s+/,shift(@regions));
debug("PVR: $#res+1 vs $regions");

# write in google maps "format"
# <h>A "fomrat" is an extremely well organized rodent</h>
open(C,">/home/barrycarter/BCINFO/sites/TEST/gmaps.txt");

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

  # for google maps
  print C "var myCoords = [\n";

  # do any of the points go outside world boundaries?
  # if so, adjust them down
  for $j (@points) {
    ($x,$y) = split(/\s+/,$j);
    $y=max(min($y,180),-180);
    $x=max(min($x,90),-90);

    # convert back from mercator
    $y = $y/$PI*180;
    $x = atan(sinh($x))/$PI*180;
    $j = "$x $y";
    debug("LL: $x,$y");
    # for google maps
    print C "new google.maps.LatLng($x, $y),\n";
  }

  debug("BET: $lat[$index],$lon[$index] ->",@points);

  # google maps wants the first point repeated (also, close off coords)
  ($x,$y) = split(/\s+/,$points[0]);
  debug("XY: $x $y *");
  print C "new google.maps.LatLng($x, $y)\n];\n";

  # get hue from temp
  # NOTE: this is my own mapping; not NOAA approved!
  debug("INDEX: $index");
  $hue=5/6-($temp[$index]/100)*5/6;
  $col=hsv2rgb($hue,1,1);
  debug("COL: $hue -> $col");

  # and now the poly itself (and push marker to array for MarkerCluster)
  print C << "MARK";

myPoly = new google.maps.Polygon({
 paths: myCoords,
 strokeColor: "$col",
 strokeOpacity: 0.8,
 strokeWeight: 0,
 fillColor: "$col",
 fillOpacity: 0.4
});

myPoly.setMap(map);

MARK
;

=item comment

var marker = new google.maps.Marker({
 position: new google.maps.LatLng($lat[$index], $lon[$index]), 
 map: map, 
 title:"$stat[$index] ($temp[$index], $hue, $index)"
});

=cut

# TODO: re-add  title:"$temp[$index]F" above

  # changing spaces to commas
  map(s/ /,/g,@points);

  # convert array to string
  $pstr = join(" ",@points);

  debug("$regions[$i] -> $pstr");

  # TODO: add semi-transparent country/state borders
  # TODO: get rid of borders on these polygons
#  print B "<polygon points='$pstr' style='fill:$col' />\n";

  # TODO: commented out text as it looks bizarre on firefox/opera
  # TODO: so need to fix that
#  print B "<text x='$lat[$index]' y='$lon[$index]' style='font-family:Verdana;font-size:0.1'>$temp[$index]</text>\n";

}

# print B "</g></svg>\n";
# close(B);

# TODO: convert to JPG for those who don't have good SVG viewers
# TODO: create continent specific maps (from same data) like weather.gov
# TODO: color map smoothly, not via polygons
# TODO: ignore older data
# TODO: do this for wind speed, humidity, dew point, etc
