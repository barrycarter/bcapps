#!/bin/perl

# Creates a Voronoi diagram (or maybe a contourplot) from temperature
# data in metarnew.db database

require "/usr/local/lib/bclib.pl";

# TODO: make sure madis.db is up-to-date enough for this to make sense
$db = "/sites/DB/madis.db";

chdir(tmpdir());

$query = "SELECT id, latitude AS y, longitude AS x, temperature FROM
madis_now WHERE time > DATETIME(CURRENT_TIMESTAMP, '-1 hour') AND type
IN ('OTHER-MTR') AND temperature!='NULL'";


# $query = "SELECT id, latitude AS y, longitude AS x, time, temperature
# FROM weather_now WHERE temperature != 'NULL'";

# $query = "SELECT id, latitude AS y, longitude AS x, time, 
# temperature+3.5/1000*elevation AS temperature
# FROM weather_now WHERE temperature != 'NULL'";

@res = sqlite3hashlist($query,$db);

debug("RES",var_dump(\@res));

# only thing we need to define is color + label
# TODO: probably need to exclude older results and build second list
# since we can't delete list entries "inline"

for $i (@res) {
  $hue = min(max(5/600*(100-$i->{temperature}),0),1);
  # for mathematica testing
  print "{$i->{x},$i->{y},$hue},\n";

  $i->{color} = hsv2rgb($hue,1,1,"kml=1&opacity=80");
  $i->{label} = "$i->{id} @ $i->{time}: $i->{temperature}F";
  # TODO: cleanup time (include METAR names + maybe ship names, buoy names?)
  debug("LABEL: $i->{label}");
}

my($file) = voronoi_map(\@res);
system("cp $file /sites/data/temperature-voronoi.kmz");

die "TESTING";

sleep(60);
in_you_endo();
exec($0);

exit(0);

# code below is for contour plotting
# TODO: split into separate file
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


