#!/bin/perl

push(@INC,"/usr/local/lib");
require "bclib.pl";

# the KML file created here is visible at
# http://wordpress.barrycarter.info/index.php/voronoi-temperature-map/

# TODO: clickable polygons are REALLY annoying, though probably can't
# fix them scriptwise

# TODO: use real 3D Voronoi, not equiangular approximation

# work in my own temp dir
chdir(tmpdir());
system("pwd");

# pull data from live weather (also available at metar.db.94y.info)
# cp avoids db lock

# system("cp /tmp/metar.db .");
# warn "Using /tmp/metar.db for testing only!";

system("cp /sites/DB/metar.db .");
@res = sqlite3hashlist("SELECT time, -strftime('%s', n.time)+strftime('%s', 'now') AS age, n.*, s.* FROM nowweather n JOIN stations s ON (n.code=s.metar) WHERE temperature IS NOT NULL AND age>0 AND age<7200", "metar.db");
debug("ERR: $SQL_ERROR");

# using "equiangular" projection, so no mapping needed
for $i (@res) {
  push(@vor, $i->{longitude}, $i->{latitude});

  # data conversion
  $i->{temperature} = $i->{temperature}*1.8 + 32;
}

@tess = voronoi(\@vor);

# write in KML format
# <h>A "fomrat" is an extremely well organized rodent</h>
open(B,">/home/barrycarter/BCINFO/sites/DATA/current-temperatures.kml");
print B << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
MARK
;

for $i (0..$#tess) {
  # line in @res corresponding to this polygon
  %hash = %{$res[$i]};

  # KML
  print B "<Placemark>\n";
  print B "<gx:balloonVisibility>0</gx:balloonVisibility>\n";
print B "<Icon><href>http://test.barrycarter.info/moon.png</href></Icon>\n";
  print B "<styleUrl>#$hash{code}</styleUrl>\n";
  print B "<title></title>\n";
  print B "<description>$hash{code} ($hash{city}, $hash{state}, $hash{country}) $hash{temperature}F ($hash{time} GMT)</description>\n";
  print B "<Polygon><outerBoundaryIs><LinearRing><coordinates>\n";

  # the points for this polygon
  for $j (@{$tess[$i]}) {
    $j=~s/ /,/;
    print B "$j\n";
  }

  # get polygon color/hue from temperature
  # NOTE: this is my own mapping; not NOAA approved!
  $hue=5/6-($hash{temperature}/100)*5/6;
  $kmlcol = hsv2rgb($hue,1,1,"kml=1&opacity=80");

  # KML end of polygon
  print B "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>\n\n";

print B << "MARK";
<Style id="$hash{code}">
<PolyStyle><color>$kmlcol</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>
MARK
;
}

# KML: end of file
print B "</Document></kml>\n";
close(B);

# TODO: point to continent specific maps (from same data) like weather.gov
# TODO: color map smoothly, not via polygons
# TODO: do this for wind speed, humidity, dew point, etc
