#!/bin/perl

push(@INC,"/usr/local/lib");
require "bclib.pl";

# work in my own temp dir
chdir(tmpdir());

# pull data from live weather (also available at metar.db.94y.info)
# (my own copy is local); cp avoids db lock
system("cp /tmp/metar-live.db .");
@res = sqlite3hashlist("SELECT -strftime('%s', replace(n.time, '-4-','-04-'))+strftime('%s', 'now') AS age, n.code, n.temperature, s.latitude, s.longitude FROM nowweather n JOIN stations s ON (n.code=s.metar) WHERE age>0 AND age<7200", "metar-live.db");

# create file for qvoronoi (header)
open(A,">/tmp/qhull-file.txt");
print A "2\n"; # dimension
print A $#res+1 . "\n"; # number of points

# create file for qvoronoi (body) and note temp for later use
for $i (@res) {
  %hash = %{$i};
  ($lat[$n], $lon[$n], $temp[$n], $stat[$n]) = 
    ($hash{latitude}, $hash{longitude}, $hash{temperature}*1.8+32, $hash{code});
  # skip NZSP Antarctica for now (boo!)
  # TODO: fix
  if ($lat[$n]<-85) {next;}

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

  debug("BEFORE: $lat[$index],$lon[$index] ->",@points);

  # for google maps
  print C "var myCoords = [\n";

  # keep track of miny and maxy just in case we have 180 condition
  ($miny, $maxy) = (180,-180);

  # do any of the points go outside world boundaries?
  # if so, adjust them down
  for $j (@points) {
    ($x,$y) = split(/\s+/,$j);

    # TODO: really need to figure out how to handle this better
#    if ($x<-1*$PI) {$x=-1*$PI;}
#    if ($x>$PI) {$x=$PI;}
    if ($y<-1*$PI) {$y=-1*$PI;}
    if ($y>$PI) {$y=$PI;}

    # TODO: restore or fix this
#    $y=max(min($y,$PI),-1*$PI);
#    $x=max(min($x,$PI/2),-1*$PI/2);

    # out of range nums tend to create problems
    # TODO: create a function or something for this; easier using "mod"?
#    while($x < -1*$PI) {$x+=2*$PI;}
#    while($x > $PI) {$x-=2*$PI;}
#    while($y < -1*$PI) {$y+=2*$PI;}
#    while($y > $PI) {$y-=2*$PI;}

    # convert back from mercator
    $y = $y/$PI*180;

    # keep track of max/min
    if ($y<$miny) {$miny=$y;}
    if ($y>$maxy) {$maxy=$y;}

    $x = atan(sinh($x))/$PI*180;
    $j = "$x $y";
    debug("LL: $x,$y");
    # for google maps
    print C "new google.maps.LatLng($x, $y),\n";
  }

  debug("AFTER: $lat[$index],$lon[$index] ->",@points);

  # google maps wants the first point repeated (also, close off coords)
  ($x,$y) = split(/\s+/,$points[0]);
  debug("XY: $x $y *");
  print C "new google.maps.LatLng($x, $y)\n];\n";

  # get hue from temp
  # NOTE: this is my own mapping; not NOAA approved!
  debug("INDEX: $index");
  $hue=5/6-($temp[$index]/100)*5/6;

  # below: testing for limited number of colors
#  $hue = floor($hue*4+.5)/4;

  $col=hsv2rgb($hue,1,1);


  debug("COL: $hue -> $col");

  debug("Y RANGE: $miny $maxy");

  if (abs($miny-$maxy) >=90) {debug("BIG Y RANGE");}

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
