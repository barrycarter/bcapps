<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0px; padding: 0px }
  #map_canvas { height: 100% }
</style>

<!-- hardcoding google key is icky but harmless -->

<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false&key=AIzaSyAGL_Xc8z1fTp8Na-stxE9u8ihnjEbkbbA">
</script>
<script type="text/javascript">

var trafficOptions = {
    getTileUrl: function(coord, zoom) {
      return "http://test.barrycarter.info/bc-mytile.pl?"+"zoom=" + zoom + "&x=" + coord.x + "&y=" + coord.y + "&client=api";
;
    },
    tileSize: new google.maps.Size(256, 256),
    opacity: 0.4
  };

var trafficMapType = new google.maps.ImageMapType(trafficOptions);
 
function initialize() {
  var myOptions = {
    zoom: 2,
    center: new google.maps.LatLng(0,0),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var map = new google.maps.Map(document.getElementById("map_canvas"),
      myOptions);

  <?php $foo = rand(); ?>

  map.zoom = 2;
  map.center = new google.maps.LatLng(0,0);
  map.overlayMapTypes.insertAt(0, trafficMapType);
}

</script>
</head>
<body onload="initialize()">

<div id="map_canvas" style="width:100%; height:100%"></div>

<a target="_blank" href="https://github.com/barrycarter/bcapps/blob/master/BCINFO3/sites/test/gettile.php">Source code on github</a>, but most of the work is gone by <a target="_blank" href="https://github.com/barrycarter/bcapps/blob/master/bc-mytile.pl">this Perl script</a>

</body>
</html>
