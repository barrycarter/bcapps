<!DOCTYPE html><html><head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<style type="text/css">
 html { height: 100% }
 body { height: 100%; margin: 0px; padding: 0px }
</style>
<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
<script type="text/javascript">
function initialize() {
  var myOptions = {
    zoom: 2,
    center: new google.maps.LatLng(0,0),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var map = new google.maps.Map(document.getElementById("map_canvas"),
      myOptions);

  // randomize to avoid caching
  kmll = new google.maps.KmlLayer('http://<?php echo rand()?>.test.barrycarter.info/temp.kml', {preserveViewport: true});
  kmll.setMap(map);
  map.zoom = 2;
  map.center = new google.maps.LatLng(0,0);
}
</script></head><body onload="initialize()">
<div id="map_canvas" style="width:100%; height:100%"></div></body></html>
