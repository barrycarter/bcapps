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

/*

Converts a slippy tile or an equirectangular tile to a latitude and longitude:

z: tile zoom value
x: tile x value (may be fractional)
y: tile y value (may be fractional)

projection: if 1, Mercator project, otherwise equirectangular project

*/

function tile2LngLat(obj) {


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

*/

function placeTilesOnMap(obj) {

}

/** transparent debugger */

function td(x, str) {
  console.log(`TD(${str}): ${x}`);
  return x;
}

