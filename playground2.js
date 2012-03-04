<html>
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<script type="text/javascript" 
 src="http://maps.google.com/maps/api/js?sensor=false">
</script>
<style type="text/css">
html { height: 100% }
body { height: 100%; margin: 0px; padding: 0px }
#map_canvas { height: 100% }
</style>
<script type="text/javascript">

function initialize() {
  var myLatLng = new google.maps.LatLng(0,0);
  var myOptions = {
    zoom: 2,
    center: myLatLng,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };

  var map = new google.maps.Map(document.getElementById("map_canvas"),
				myOptions);

  pt = new google.maps.LatLng(-6.16641733867847,298.952836707632);
  ap = new google.maps.LatLng(6.16641733867847,478.952836707632);

  new google.maps.Marker({
    position: pt,
	map: map,
	Icon: "http://test.barrycarter.info/sun.png",
	title:"Sun"
	});

  new google.maps.Marker({
    position: ap,
	map: map,
	Icon: "http://test.barrycarter.info/nemesis.png",
	title:"Nemesis"
	});
</script>

</head><body onload="initialize()">
  <div id="map_canvas" style="width:100%; height:100%"></div>
</body>
</html>
