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

# style for dots (currently a constant)
print B << "MARK";
<Style id="dot"><IconStyle>
<Icon><href>http://test.barrycarter.info/red7.png</href></Icon>
</IconStyle></Style>
MARK
;

for $i (0..$#tess) {
  # line in @res corresponding to this polygon
  %hash = %{$res[$i]};

  # KML
print B << "MARK";
<Placemark>
<styleUrl>#$hash{code}</styleUrl>
<description>$hash{code} ($hash{city}, $hash{state}, $hash{country}) 
 $hash{temperature}F ($hash{time} GMT)</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
MARK
;

  # the points for this polygon
  # google handles pointless polygons fine
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

  # google dislikes polygons too close to the poles
  if (abs($hash{latitude}) > 85) {next;}

  # tiny polygon that effectively acts as an icon
  # TODO: adjust for mercator projection
  my(@range) = ($hash{longitude}-.01, $hash{longitude}+.01,
                $hash{latitude}-.01, $hash{latitude}+.01);

=item comment

  print B << "MARK";
<Placemark>
<styleUrl>#$hash{code}</styleUrl>
<description>station $n</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
$range[0],$range[2]
$range[1],$range[2]
$range[1],$range[3]
$range[0],$range[3]
</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>
MARK
;

=cut

}

# KML: end of file
print B "</Document></kml>\n";
close(B);

# ran into google's 3M limit, wow! 
# http://code.google.com/apis/kml/documentation/mapsSupport.html

system("zip /home/barrycarter/BCINFO/sites/DATA/current-temperatures.kmz /home/barrycarter/BCINFO/sites/DATA/current-temperatures.kml");

# TODO: point to continent specific maps (from same data) like weather.gov
# TODO: color map smoothly, not via polygons
# TODO: do this for wind speed, humidity, dew point, etc
