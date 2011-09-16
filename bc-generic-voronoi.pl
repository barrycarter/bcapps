#!/bin/perl

# Copied bc-temperature-voronoi to bc-generic-voronoi to clean it up
# and, more importantly, make it generic for any db/color scheme/etc

# TODO: could genercize to any list of hashs (where hashs contain
# latitude/longitude/color/label/id)

push(@INC,"/usr/local/lib");
require "bclib.pl";

for $i (1..5000) {
#  srand(++$seed*2);
  $x = rand()*360-180;
  $y = rand()*180-90;
  $hashref = {};
  %{$hashref}=(
	       "x" => $x,
	       "y" => $y,
	       "color" => hsv2rgb(rand(),1,1,"kml=1&opacity=80"),
	       "label" => "$x,$y",
	       "id" => ++$n
	      );
  push(@data, $hashref);
}

debug("DATA",@data);

voronoi_map(\@data);

die "TESTING";

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

}

# KML: end of file
print B "</Document></kml>\n";
close(B);

# zip to reduce chance of 3M limit issue
# http://code.google.com/apis/kml/documentation/mapsSupport.html

$kmz = $kmlout;
$kmz=~s/\.kml/\.kmz/isg;

system("zip $kmz $kmlout");

# TODO: color map smoothly, not via polygons

=item voronoi_map(\@hashlist, $options)

Given @hashlist, a list of hashrefs, return a KML map (string)
representing the voronoi diagram. Each hash must have at least these
keys: id, x, y, label, color (KML-style); id must be unique

Primarily intended for latitude/longitude "google style" maps

$options currently unused

TODO: this seems to leave off one (or more?) points, not sure why

=cut

sub voronoi_map {
  my($hashlistref, $options) = @_;
  my(@hashlist) = @{$hashlistref};

  # header/footer
  my($header) = read_file("kmlhead.txt");
  my($footer) = read_file("kmlfoot.txt");
  print "$header\n";

  # the Voronoi diagram
  my(@vor);
  for $i (@hashlist) {
    debug("I: $i");
    push(@vor, $$i{x}, $$i{y});
  }
  my(@tess) = voronoi(\@vor);

  debug("TESS",@tess,"ENDTESS");

  # the chunk for each polygon
  for $i (0..$#tess) {
    # not each point pair has a polygon
    unless ($tess[$i]) {next;}
    my(@points);
    # hash in @hashlist corresponding to this polygon
    my(%hash) = %{$hashlist[$i]};
    debug("I: $tess[$i], II: %hash");
    # polygon header
    my($body) = << "MARK";
<Placemark><styleUrl>#$hash{id}</styleUrl>
<description>$hash{label}</description>
<Polygon><outerBoundaryIs><LinearRing><coordinates>
MARK
;
    # style URL
    my($style) = << "MARK";
<Style id="$hash{id}">
<PolyStyle><color>$hash{color}</color>
<fill>1</fill><outline>0</outline></PolyStyle></Style>
MARK
;

    # the points for this polygon (pointless polygons OK w/ google)
    for $j (@{$tess[$i]}) {
    $j=~s/ /,/;
    push(@points, $j);
  }
    my($tail) = "</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>";

    print "$body\n",join("\n",@points),"\n","\n$tail\n",$style,"\n";
  }

  print $footer;

}





