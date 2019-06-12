// functions that will eventually be in bclib.js

/**

Create the base64 representation of PNG image from an 3D array of (r,
g, b, a) values. Obj fields:

arr - the 3D array

*/

function array2PNG(obj) {

  let imageData = new ImageData(obj.arr[0].length, obj.arr.length);

  // TODO: there must be a better way to do this

  let flat = obj.arr.flat(3);

  for (let i=0; i < flat.length; i++) {imageData.data[i] = flat[i];}

  // the 'canvas' here is a tag/type name not a DOM element name

  let canvas = document.createElement('canvas');

  // set width and height

  canvas.height = obj.arr.length;
  canvas.width = obj.arr[0].length;

  canvas.getContext('2d').putImageData(imageData, 0, 0);
  return canvas.toDataURL();
}

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

For a given slippy tile, determine which points are more distant than
given distances

TODO: this function might be too slow to be usable

TODO: some efficiency speedups possible including caching trig functions

Inputs:

TODO: add more here

lng: longitude of target point
lat: latitude of target point

distances: the target distances in km (because turfjs defaults to that)

z/x/y: the z, x, and y values of the tile

TODO: add "scalable" distances (not array based)

*/

function tilePixels2DistanceBand (obj) {

  /* determine the nw corner of this tile and of the tile to the SE */

  let nw = tile2LngLat(obj);
  let se = tile2LngLat({x: obj.x+1, y: obj.y+1, z: obj.z});

  console.log(td(nw, "nw"), td(se, "se"));

  /* the results array */

  let result = [];

  /* go through pixels row by row, col by col */

  // TODO: this uses the nw corner of each pixel, should use middle

  // TODO: subroutinize below, could be useful in other contexts

  // TODO: create function that returns distances, "banding" is too
  // restrictive
  
  for (let i=0; i < 256; i++) {
    result[i] = [];
    for (let j=0; j < 256; j++) {

      let plng = nw.lng + i/256*(se.lng-nw.lng);
      let plat = nw.lat + j/256*(se.lat-nw.lat);
      let dist = turf.distance([plng, plat], [obj.lng, obj.lat]);

      // where in distances does this dist appear?
      // TODO: binary search would be faster for large arrays
      // NOTE: value of i means "less than the ith element"
      
      // start with assumption it's less than 0th element and then loop
      
      result[i][j] = 0;

      for (let k=0; k < obj.distances.length; k++) {

	// array is sorted, so this is early abort
	if (dist < obj.distances[k]) {break;}
	result[i][j] = k+1;
      }
    }
  }
  return result;
}
