#!/bin/perl

# Does what bc-image-overlay does, without KML

# Given an image on my server (bcinfo3) and other parameters, create
# google map with that image. Options (given as GET variables to the URL):


# center = lat,lon center of map (in that order)
# zoom = google zoom level
# maptypeid = google map type (HYBRID, ROADMAP, TERRAIN, SATELLITE)
# refresh = refresh every this many seconds
# url = the url of the image ON MY SERVER you want to see
# marker = place marker at lat,lon (in that order)
# s= n= e= w= the east/west/north/south longitude/latitudes of where to place the image

# TODO: fix below
# sample URL: http://test.bcinfo3.barrycarter.info/bc-image-overlay.pl?center=35.1,-106.55&zoom=13&maptypeid=HYBRID&url=conus.kml&refresh=60

require "/usr/local/lib/bclib.pl";

# query string will determine most chars (incl KML map in question)
my($query) = $ENV{QUERY_STRING};
$query=~s/[^a-z0-9_\.\=\&\,\-]//isg;
# by making defaults come first, $query stuff will override
# NOTE: default of entire world is REALLY ugly + doesn't work well (Mercator)
$defaults = "center=0,0&zoom=2&maptypeid=HYBRID&s=-90&n=90&e=180&w=-180";
my(%query) = str2hash("$defaults&$query");

# image comments (if any)
my($out,$err,$res) = cache_command2("identify -verbose /sites/data/$query{url} | fgrep Comment:");

# refresh header?
if ($query{refresh}) {print "Refresh: $query{refresh}\n";}
print "Content-type: text/html\n\n";

# security check (empty URL is allowed)
unless ($query{url}=~/^[a-z0-9_\.\-]*$/i) {
  print "Your URL, $query{url}, frightens me!\n";
  exit(0);
}

# user marker (in lat,lng format, very simple, nothing fancy)
if ($query{marker}) {
  $markstring = << "MARK";
var marklatlng = new google.maps.LatLng($query{marker});
var marker = new google.maps.Marker({position: marklatlng,map: map});
MARK
;
}

my($str) = << "MARK";
<html><head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0px; padding: 0px }
  #map_canvas { height: 100% }
</style>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">

// these must exist outside initialize because i use them globally
var map;
var gl;

function initialize() {
 var myLatLng = new google.maps.LatLng($query{center});
 var myOptions = {zoom: $query{zoom}, center: myLatLng, mapTypeId: google.maps.MapTypeId.$query{maptypeid}, scaleControl: true};
 map = new google.maps.Map(document.getElementById("map_canvas"),myOptions);
 var imageBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng($query{s},$query{w}),
    new google.maps.LatLng($query{n},$query{e}));

 gl = new google.maps.GroundOverlay(
    "http://data.bcinfo3.barrycarter.info/$query{url}",
    imageBounds);
 gl.setMap(map);
 $markstring
}

// this function, outside initialize, allows changing the overlayed image
function chgimg(img) {
 gl.setMap();
 gl.url="http://data.bcinfo3.barrycarter.info/"+img;
 gl.setMap(map);
}

</script></head>
<body onload="initialize()"><div id="map_canvas" style="width:100%; height:100%"></div>
MARK
;

print $str;

if ($out) {print "Image $out<p>\n";}

# these URLs are for testing only
for $i ("Conus_20130917_1918_N0Ronly.gif.png", 
	"Conus_20130917_1908_N0Ronly.gif.png", 
	"Conus_20130917_1858_N0Ronly.gif.png", 
	"Conus_20130917_1838_N0Ronly.gif.png",
	"Conus_20130917_1848_N0Ronly.gif.png") {
  print qq%<a href='javascript:chgimg("$i")'>$i</a>\n%;
}

print "<p>Source: https://github.com/barrycarter/bcapps/blob/master/MAPS/bc-image-overlay-nokml.pl<br>See also: https://github.com/barrycarter/bcapps/blob/master/MAPS/<br>\n";

print "</body></html>\n";

# TODO: add instructions re how to change zoom, map type, refresh, center, etc (to the actual page where this is displayed)

