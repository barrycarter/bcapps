#!/bin/perl

# Given a KML on my server (bcinfo3), create google map with that KML
# file, using randomization to prevent caching

require "/usr/local/lib/bclib.pl";

print "Content-type: text/html\n\n";

# query string will determine most chars (incl KML map in question)
my($query) = $ENV{QUERY_STRING};
$query=~s/[^a-z0-9_\.\=\&\,\-]//isg;
# by making defaults come first, $query stuff will override
$defaults = "center=0,0&zoom=2&maptypeid=TERRAIN";
my(%query) = str2hash("$defaults&$query");

# the given URL parameter is assumed to be in
# data.bcinfo3.barrycarter.info and is randomized to prevent caching

# TODO: randomize!
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
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">
function initialize() {
 var myLatLng = new google.maps.LatLng($query{center});
 var myOptions = {zoom: $query{zoom}, center: myLatLng, mapTypeId: google.maps.MapTypeId.$query{maptypeid}};
 var map = new google.maps.Map(document.getElementById("map_canvas"),myOptions);
 var kmllayer = new google.maps.KmlLayer('$kmlurl');
 kmllayer.setMap(map);
}
</script></head>
<body onload="initialize()"><div id="map_canvas" style="width:100%; height:100%"></div>
MARK
;

print $str;

print "<p>Viewing: $kmlurl\n";

print "</body></html>\n";
