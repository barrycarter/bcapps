#!/bin/perl

# Given a KML on my server (bcinfo3), create google map with that KML
# file, using randomization to prevent caching

# TODO: allow scale/rotate/etc controls to be turned off

# TODO: opacity (can't do easily w/ KML files)

# sample URL: http://test.bcinfo3.barrycarter.info/bc-image-overlay.pl?center=35.1,-106.55&zoom=13&maptypeid=HYBRID&url=conus.kml&refresh=60

require "/usr/local/lib/bclib.pl";

# query string will determine most chars (incl KML map in question)
my($query) = $ENV{QUERY_STRING};
$query=~s/[^a-z0-9_\.\=\&\,\-]//isg;
# by making defaults come first, $query stuff will override
$defaults = "center=0,0&zoom=2&maptypeid=HYBRID&rotateControl=true&scaleControl=true&overviewMapControl=true";
my(%query) = str2hash("$defaults&$query");

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

# the given URL parameter is assumed to be in
# data.bcinfo3.barrycarter.info and is randomized to prevent caching
$rand = int(rand()*2**32);
$kmlurl = "http://$rand.data.bcinfo3.barrycarter.info/$query{url}";

my($str) = << "MARK";
<html><head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0px; padding: 0px }
  #map_canvas { height: 100% }
</style>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false&key=$google_maps_key"></script>
<script type="text/javascript">
function initialize() {
 var myLatLng = new google.maps.LatLng($query{center});
 var myOptions = {zoom: $query{zoom}, center: myLatLng, mapTypeId: google.maps.MapTypeId.$query{maptypeid}, scaleControl: $query{scaleControl}, rotateControl: $query{rotateControl}, overviewMapControl: $query{overviewMapControl}};

// var searchBox = new google.maps.places.SearchBox(input);

 var map = new google.maps.Map(document.getElementById("map_canvas"),myOptions);
 var kmlLayerOptions = {preserveViewport:true};
 var kmllayer = new google.maps.KmlLayer('$kmlurl',kmlLayerOptions);
 kmllayer.setMap(map);
 $markstring
}
</script></head>
<body onload="initialize()"><div id="map_canvas" style="width:100%; height:100%"></div>
MARK
;

print $str;

print "<p>Viewing: $kmlurl<br>\n";

# if the KML has a description tag, display it here
my($out,$err,$res) = cache_command2("fgrep -i '<description>' /sites/data/$query{url}");
if ($out) {
  $out=~s/<.*?>//isg;
  print "Description: $out<br>\n";
}

print "<p>Source: https://github.com/barrycarter/bcapps/blob/master/MAPS/bc-image-overlay.pl<br>See also: https://github.com/barrycarter/bcapps/blob/master/MAPS/<br>\n";

print "</body></html>\n";

# TODO: add instructions re how to change zoom, map type, refresh, center, etc

