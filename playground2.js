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

var startime = new Date();

function initialize() {
  var myLatLng = new google.maps.LatLng(0,0);
  var myOptions = {
    zoom: 2,
    center: myLatLng,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };

  var map = new google.maps.Map(document.getElementById("map_canvas"),
      myOptions);

pt = new google.maps.LatLng(-6.16453214907868,297.19423018679);
ap = new google.maps.LatLng(6.16453214907868,477.19423018679);

test = new google.maps.LatLng(35,-106);

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

var light = new Array();
var dark = new Array();

for (r=1; r<=15; r++) {
 var nowtime = new Date();
   light.push(new google.maps.Circle({
 center: pt,
 radius: 667917*r,
 map: map,
 strokeWeight: 0.1,
 fillOpacity: 0.01,
 fillColor: "#ffffff"
		  }));

 dark.push(new google.maps.Circle({
 center: ap,
 radius: 667917*r,
 map: map,
 strokeWeight: 1,
 fillOpacity: 0,
 fillColor: "#ffffff"
}));

}

function moveme() {
 nowtime = (new Date()-startime)/1000;
 newsun = new google.maps.LatLng(-6.16453214907868,297.19423018679-nowtime/1);
// alert(nowtime);
 for (r=1; r<=15; r++) {
  light[r].setCenter(newsun);
}
}

window.setInterval(moveme, 1000);

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
