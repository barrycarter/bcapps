// functions that will eventually be in bclib.js

/**

TODO: this function is probably unnecessary

Converts an equirectangular tile to an array of latitude and
longitudes, similar to tile2LngLat, but returning more than just the
top left corner; this is faster than calling tile2LngLat w/ fractional
values, hopefully

z: tile zoom value
x: tile x value
y: tile y value

*/

function tile2LngLatPixels(obj) {

  /* determine the nw corner of this tile */

  let nw = tile2LngLat(obj);

  /* the width of a pixel in both lng and lat */

  let di = 360/2**obj.z;
  let dj = 180/2**obj.z;

  for (let i=nw.lng; i < nw.lng+256*di; i += di) {
    for (let j=nw.lat; j > nw.lat-256*dj; j += dj) {
      console.log(`I: ${i}, J: ${j}`);
    }
  }
}

/**

WARNING: this functions signature will change to use multiple dist
values-- DO NOT USE AS IS

For a given slippy tile, determine which points are more distant than
given distances

TODO: this function might be too slow to be usable

TODO: some efficiency speedups possible including caching trig functions

Inputs:

TODO: add more here

lng: longitude of target point
lat: latitude of target point

dist: the target distances in km (because turfjs defaults to that)


*/

function placeTileBuffersOnMap (obj) {

  console.log("CALLED");

  /* determine the nw corner of this tile */

  let nw = tile2LngLat(obj);

  /* and zoom level */
  let z = boundNumber(obj.map.getZoom(), obj.minZoom, obj.maxZoom);

  /* the width of a pixel in both lng and lat */

  let di = 360/2**z;
  let dj = 180/2**z;

  console.log(`NW: ${nw.lng} and ${nw.lng}, DI: ${di}, DJ: ${dj}`);

  for (let i=nw.lng; i < nw.lng+256*di; i += di) {
    for (let j=nw.lat; j > nw.lat-256*dj; j -= dj) {
      console.log(`I: ${i}, J: ${j}`);
    }
  }
}

