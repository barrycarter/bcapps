#!/bin/perl

# Creates a Voronoi diagram (or maybe a contourplot) from temperature
# data in metarnew.db database

require "/usr/local/lib/bclib.pl";

# temporary db for testing (is local)
$db = "/home/barrycarter/20130908/metarnew.db";

chdir(tmpdir());
# TODO: does not include SYNOP/RAWS
$metar_query = "SELECT station_id AS id, latitude AS y,
longitude AS x, observation_time AS time, 'METAR' AS source,
temp_c*1.8+32 AS temp_f FROM metar_now";
$buoy_query = "SELECT STN AS id, LAT AS y, 
LON AS x, YYYY*10000+MM*100+DD+hh/100.+mm/10000. AS time, 'BUOY' AS source,
ATMP*1.8+32 AS temp_f FROM buoy_now WHERE ATMP!='MM'";
$ship_query = "SELECT station_id, latitude, longitude, 'SHIP' AS source,
temp_c*1.8+32 AS temp_f FROM ship_now WHERE temp_c!=''";

$query = "$metar_query UNION $buoy_query UNION $ship_query";
$query = "$metar_query UNION $buoy_query";

@res = sqlite3hashlist($query,$db);

# only thing we need to define is color + label
for $i (@res) {
  # ignore bad entries
  # TODO: not all 0 temps are bad!
  # TODO: should ignore on original value, not converted value
  if ($i->{temp_f}==32) {
    # this doesnt really delete the hash, but voronoi_map will ignore it
    delete $i{id};
    next;
  }
  $hue = min(max(5/600*(100-$i->{temp_f}),0),1);
  $i->{color} = hsv2rgb($hue,1,1,"kml=1&opacity=80");
  $i->{label} = "$i->{id} @ $i->{time}: $i->{temp_f}F";
  debug("LABEL: $i->{label}");
}

my($file) = voronoi_map(\@res);
system("cp $file /tmp/vtest1.kmz");

die "TESTING";

# mathematica format (testing)
my(@print);
for $i (@res) {
  # this is an error that I've fixed, but need to ignore for now
  if ($i->{longitude}=~/\-$/) {next;}
  # not sure what causes this..
  if (abs($i->{latitude})>90) {next;}

  push(@print,"{$i->{longitude}, $i->{latitude}, $i->{temp_f}}");
}

# have mathematica create a contourplot
open(A,">math.m");

# the list
print A "list = {\n";
print A join(",\n",@print);
print A "};\n";
# right now, USA only for testing (color convention same as bc-voronoi)
print A << "MARK";
hue[t_] = Min[Max[5/600*(100-t),0],1];
g = ListContourPlot[list, ColorFunction -> (Hue[hue[#1]]&), Contours -> 256,
 PlotRange->{{-180,180},{-90,90}}, ContourStyle -> None, Frame -> None,
  ColorFunctionScaling -> False]
Export["/tmp/temp.svg",g]
Exit[];
MARK
;

close(A);

system("math -initfile math.m");
system("cp math.m /tmp");

# semi-transparentize
system("convert /tmp/math.png -alpha on -channel Alpha -evaluate Divide 2 /tmp/math2.png");


