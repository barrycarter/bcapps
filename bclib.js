/**

Given a string that looks like an HTTP QUERY_STRING, convert it to a
hash. This is one of the few functions here that does NOT take a hash
as its argument

*/

function str2hash(str) {

  let returnHash = {};

  console.log(str.split("&"));

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

*/

function placeTilesOnMap(obj) {

}

