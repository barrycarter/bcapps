<meta http-equiv="refresh" content="60">
Last updated: Sun Mar 4 16:30:03 GMT 2012
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
<style type="text/css">
  html { height: 100% }
  body { height: 100%; margin: 0px; padding: 0px }
  #map_canvas { height: 100% }
</style>
<script type="text/javascript"
    src="http://maps.google.com/maps/api/js?sensor=false">
</script>
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

// BEGIN INSERTED CODE

pt = new google.maps.LatLng(-6.16453214907868,297.19423018679);
ap = new google.maps.LatLng(6.16453214907868,477.19423018679);

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


new google.maps.Circle({
 center: pt,
 radius: 10018760,
 map: map,
 strokeWeight: 2,
 fillOpacity: 0.2,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 10018760,
 map: map,
 strokeWeight: 1,
 fillOpacity: 0.2,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 9350842.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 9350842.66666667,
 map: map,
 strokeWeight: 1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 8682925.33333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 8682925.33333333,
 map: map,
 strokeWeight: 1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 8015008,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 8015008,
 map: map,
 strokeWeight: 1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 7347090.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 7347090.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 6679173.33333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 6679173.33333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 6011256,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 6011256,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 5343338.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 5343338.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 4675421.33333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 4675421.33333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 4007504,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 4007504,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 3339586.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 3339586.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 2671669.33333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 2671669.33333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 2003752,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 2003752,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 1335834.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 1335834.66666667,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


new google.maps.Circle({
 center: pt,
 radius: 667917.333333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
});

new google.maps.Circle({
 center: ap,
 radius: 667917.333333333,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0,
 fillColor: "#000000"
});


mpt = new google.maps.LatLng(17.3185462836248,68.9703629502967);

new google.maps.Circle({
 center: mpt,
 radius: 10018760,
 map: map,
 strokeWeight: 2,
 strokeColor: "#ffffff",
 fillOpacity: 0,
 fillColor: "#ffffff"
});

new google.maps.Marker({
 position: mpt,
 map: map,
 Icon: "http://test.barrycarter.info/moon.png",
 title:"Moon"
});


}

</script>
</head>
<body onload="initialize()">
  <div id="map_canvas" style="width:100%; height:100%"></div>
</body>
</html>
