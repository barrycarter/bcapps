/**

General notes:

lng = longitude (not lon or long)


*/


/**

Dumps an object as a string

*/

function var_dump(obj) {
  let out = '';
  for (var i in obj) {
    out += i + ": " + obj[i] + "\n";
  }
  return out;
}

/**

Given a string that looks like an HTTP QUERY_STRING, convert it to a
hash. This is one of the few functions here that does NOT take a hash
as its argument

NOTE: there are probably more clever ways to do this

*/

function str2hash(str) {

  let returnHash = {};

  str.split("&").forEach(function(kv) {
      let arr = kv.split("=");
      returnHash[arr[0]] = arr[1];
    });

  return returnHash;

}

/**

Given two hashes, merge them where first overrides second for matching keys

*/

function mergeHashes(obj1, obj2) {

  let returnHash = {};

  Object.keys(obj2).forEach(function (key) {returnHash[key] = obj2[key]});
  Object.keys(obj1).forEach(function (key) {returnHash[key] = obj1[key]});
  
  return returnHash;
}  

/*

Converts a slippy tile or an equirectangular tile to a latitude and longitude:

z: tile zoom value
x: tile x value (may be fractional)
y: tile y value (may be fractional)

projection: if 1, Mercator project, otherwise equirectangular project

*/

function tile2LngLat(obj) {

  // set defaults

  obj = mergeHashes(obj, str2hash("projection=0"));

  // true for both projections
  let lng = obj.x/2**obj.z*360-180;

  if (obj.projection == 0) {
    return {lng: lng, lat: 90-obj.y/2**obj.z*180}
  }

  // for Mercator (http://mathworld.wolfram.com/MercatorProjection.html)
  // TODO: this is hideous

  let lat = 180/Math.PI*(Math.PI/2-2*Math.atan(Math.exp((obj.y/2**obj.z-1/2)*2*Math.PI)));

  return {lng: lng, lat: lat};

}

/*

Converts a latitude and longitude to a slippy tile or an equirectangular tile

z: tile zoom value
lat: the latitude
lng: tile longitude

projection: if 1, Mercator project, otherwise equirectangular project

*/

function lngLat2Tile(obj) {

  // set defaults

  obj = mergeHashes(obj, str2hash("projection=0"));

  // true for both projections
  let x = (obj.lng+180)/360*2**obj.z;

  // for equirectangular
  if (obj.projection == 0) {
    return {z: obj.z, x: x, y: (90-obj.lat)/180*2**obj.z};
  }

  // for Mercator
  // TODO: I copied this from somewhere else and am NOT happy about it

  // for Mercator (http://mathworld.wolfram.com/MercatorProjection.html)

  let lat_rad = obj.lat/180*Math.PI;
  let y = 2**obj.z*(-Math.log(Math.tan(lat_rad) + 1/Math.cos(lat_rad))/2/Math.PI+1/2);
  return {z: obj.z, x: x, y: y};
}
  

/**

Place slippy tiles or equirectangular tiles on a Leaflet "map"
(canvas?) given the following in a hash:

map: put the tiles here

tileURL: template for tile URLs

minZoom: never get tiles lower than this zoom level

maxZoom: never get tiles higher than this zoom level

projection: if 1, assume tiles are Mercator projected (slippy tiles);
otherwise, assume they are equirectangular

opacity; tile opacity

fake: if set to 1, don't do anything, just print out debugging info

*/

function placeTilesOnMap(obj) {

  obj = mergeHashes(obj, str2hash("minZoom=0&maxZoom=999&projection=0&opacity=1"));

  let mapBounds = obj.map.getBounds();

  // compute min/max lat/lon truncating at limits

  console.log(mapBounds.getWest());


}

/** transparent debugger */

function td(x, str) {
  console.log(`TD(${str}): `, var_dump(x));
  return x;
}

