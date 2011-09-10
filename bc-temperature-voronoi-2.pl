#!/bin/perl

# NOTE: yes, I realize the whole point of GIT is to avoid creating a
# "-2" version of something. I'm using latest GIT versions in
# production so I must do it this way, sigh.

push(@INC,"/usr/local/lib");
require "bclib.pl";

# the KML file created here is visible at
# http://wordpress.barrycarter.info/index.php/(something)
# see the blog for details

# work in my own temp dir
chdir(tmpdir());

# cp avoids db lock
system("cp /sites/DB/metar.db .");
@res = sqlite3hashlist("SELECT time, -strftime('%s', n.time)+strftime('%s', 'now') AS age, n.*, s.* FROM nowweather n JOIN stations s ON (n.code=s.metar) WHERE temperature IS NOT NULL AND age>0 AND age<7200", "metar.db");

# using "equiangular" projection, so no mapping needed
for $i (@res) {push(@vor, $i->{longitude}, $i->{latitude});}
@tess = voronoi(\@vor);

# things we will map
# note use of 'temperature' (singular) to avoid conflict w/ live version
@items = ("temperature", "humidity", "dewpoint", "windspeed", "cloudiness");

# KML header
$str = << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
MARK
;

for $i (@items) {
  # data{$i} = contents file we will output to disk when done (joined w/ \n)
  push(@{$data{$i}}, $str);
}

for $i (0..$#tess) {
  # line in @res corresponding to this polygon
  %hash = %{$res[$i]};

  for $j (@items) {
    # get the color (and, later, description) for this item
    ($color, $desc) = get_color_desc($j, \%hash);

    # KML for the style
    $kmlstyle = << "MARK";
<Style id="$hash{code}-$j">
<PolyStyle><color>$color</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>
MARK
;

    # KML for polygon (start)
    $kmlstr = << "MARK";
<Placemark>
<styleUrl>#$hash{code}-$j</styleUrl>
<description>$desc</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
MARK
;

  # the points for this polygon
  @points = ();
  for $k (@{$tess[$i]}) {
    $k=~s/ /,/;
    push(@points, $k);
  }

  # KML end of polygon
  $polyend = "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>\n\n";

  # append to file
push(@{$data{$j}}, $kmlstyle, $kmlstr, $points, $polyend);
}
}

debug(unfold(%data));

die "TESTING";

# KML: end of file
print B "</Document></kml>\n";
close(B);

# ran into google's 3M limit, wow! 
# http://code.google.com/apis/kml/documentation/mapsSupport.html

system("zip /home/barrycarter/BCINFO/sites/DATA/current-temperatures.kmz /home/barrycarter/BCINFO/sites/DATA/current-temperatures.kml");

# TODO: point to continent specific maps (from same data) like weather.gov
# TODO: color map smoothly, not via polygons
# TODO: do this for wind speed, humidity, dew point, etc

sub get_color_desc {}
