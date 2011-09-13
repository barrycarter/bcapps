#!/bin/perl

# Copied bc-temperature-voronoi to bc-generic-voronoi to clean it up
# and, more importantly, make it generic for any db/color scheme/etc

push(@INC,"/usr/local/lib");
require "bclib.pl";

# START INPUTS (these are inputs to the program)

# SQLite3 db to query
$db = "/sites/DB/metar.db";

# the query (must return 'latitude' and 'longitude' columns
$query = "SELECT time, -strftime('%s', n.time)+strftime('%s', 'now') AS
age, n.*, s.* FROM nowweather n JOIN stations s ON (n.code=s.metar)
WHERE temperature IS NOT NULL AND age>0 AND age<7200";

# where the KML file is written
$kmlout = "/tmp/testing.kml";

# Function that, given a row returned by $query (as a hash), returns a
# hash that contains at least "label" and "color" (in KML-friendly
# format), and a UNIQUE id

sub describe {
  my(%hash) = @_;
  my(%rethash);

  $rethash{label}="This is a label";
  $rethash{color}="#80009bff";
  $rethash{id} = ++$count;

  return %rethash;
}

# END INPUTS

# work in my own temp dir + copy db locally
chdir(tmpdir());
system("cp $db my.db");

# query
@res = sqlite3hashlist($query, "my.db");

# Voronoi-ify
for $i (@res) {push(@vor, $i->{longitude}, $i->{latitude});}
@tess = voronoi(\@vor);

# write in KML format
open(B,">$kmlout");
print B << "MARK";
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
MARK
;

for $i (0..$#tess) {
  # line in @res corresponding to this polygon
  %hash = %{$res[$i]};
  # TODO: using the same variable here is ugly, but I'm lazy
  %hash = describe(%hash);

  # KML
print B << "MARK";
<Placemark><styleUrl>#$hash{id}</styleUrl>
<description>$hash{label}</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
MARK
;

  # the points for this polygon (pointless polygons OK w/ google)
  for $j (@{$tess[$i]}) {
    $j=~s/ /,/;
    print B "$j\n";
  }

  # KML end of polygon
  print B "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>\n\n";

print B << "MARK";
<Style id="$hash{id}">
<PolyStyle><color>$hash{color}</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>
MARK
;

# KML: end of file
print B "</Document></kml>\n";
close(B);

# zip to reduce chance of 3M limit issue
# http://code.google.com/apis/kml/documentation/mapsSupport.html

system("zip /home/barrycarter/BCINFO/sites/DATA/current-temperatures.kmz /home/barrycarter/BCINFO/sites/DATA/current-temperatures.kml");

# TODO: color map smoothly, not via polygons

