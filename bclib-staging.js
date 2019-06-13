// functions that will eventually be in bclib.js

/**

The URLCache object (not function) stores the base64 representations
of URLs and returns those when possible; when not possible, returns
the URL itself

TODO: why can't I use 'this' deeper inside my promise function

*/

let URLCache = {cache: []};

URLCache.get = function (url) {

  // if we have it in the cache, return it
  if (this.cache[url]) {
    console.log(`Returning ${url} value from cache`);
    return this.cache[url];
  }

  // if not, return the URL itself, but fetch it and store it
  fetch(url).then(function (response) {
      response.blob().then(function (b) {
	  let blobURL = URL.createObjectURL(b);
	  URLCache.cache[url] = blobURL;
	})
	})

  return url;
}

/**

Places a buffer around a point on a map. Obj properties:

map: put the tiles here

lng, lat: the longitude and latitude of the target point

TODO: allow multiple buffers?

colorFunction: a function that translates distances into RGB color values

minZoom: never get tiles lower than this zoom level

maxZoom: never get tiles higher than this zoom level

projection: if 1, assume tiles are Mercator projected (slippy tiles);
otherwise, assume they are equirectangular

opacity: tile opacity

fake: if set to 1, don't do anything, just print out debugging info

*/

function placeBufferOnMap(obj) {

  // figure out which tiles we need
  let tiles = map2TilesNeeded(obj);

  for (let i=0; i < tiles.length; i++) {

    //    console.log("TILE", tiles[i]);
    
    let bounds = tiles[i].bounds;

    //    console.log("BOUNDS", bounds);

    // get array of distances for this tile
    let dists = grid2Distances({
      lat: obj.lat, lng: obj.lng,
      width: 256, height: 256, 
      slat: bounds[0][0], nlat: bounds[1][0],
      wlng: bounds[0][1], elng: bounds[1][1]});
  
     let cols = dists.map(arr => arr.map(dist => obj.colorFunction(dist)));

     let img = array2PNG({arr: cols});

     //     console.log("OVERLAYING");
     L.imageOverlay(img, bounds, {opacity: obj.opacity}).addTo(obj.map);
     //     console.log("DONE OVERLAYING");
  }
}

/**

Given a Leaflet map, determine which slippy tiles need to be painted
on to it, and where; this function avoids repeating code in different
map rendering functions. Obj properties:

map: the map on which to render the tiles

minZoom: never get tiles lower than this zoom level

maxZoom: never get tiles higher than this zoom level

projection: if 1, Mercator projection, otherwise Plate-Carree

TODO: allow cylinderical wraparound for east/west

TODO: dragon tiles?

*/

function map2TilesNeeded(obj) {

  let result = [];

  // defaults
  obj = mergeHashes(obj, str2hash("minZoom=0&maxZoom=999&projection=0"));

  // TODO: in theory, could determine optimal zoom from map height/width
  
  let z = boundNumber(obj.map.getZoom(), obj.minZoom, obj.maxZoom);

  let mapBounds = obj.map.getBounds();

  // for Mercator, latitude limit is special; otherwise, 90

  // the +1 below is so we still get the northern/southernmost tiles

  let latLimit = obj.projection==1?bclib.MERCATOR_LAT_LIMIT+1:90;

  // compute min/max lat/lon truncating at limits

  // NOTE: this could be done better if we let lngLat2Tile() truncate

  let n = boundNumber(mapBounds.getNorth(), -latLimit, latLimit);
  let s = boundNumber(mapBounds.getSouth(), -latLimit, latLimit);
  let e = Math.min(Math.max(-180, mapBounds.getEast()), 180);
  let w = Math.min(Math.max(-180, mapBounds.getWest()), 180);

  // determine the x and y values corresponding to these extents (we
  // use 'floor' here because a tile starts at its nw boundary)

  // the corner boundaries (in this order so se > nw in both coords)

  // TODO: not happy with the way I am floor-ifying these

  let nw = applyFunctionToHashValues({hash: lngLat2Tile({z: z, lat: n, lng: w, projection: obj.projection}), f: Math.floor}).hash;
  let se = applyFunctionToHashValues({hash: lngLat2Tile({z: z, lat: s, lng: e, projection: obj.projection}), f: Math.floor}).hash;

  // and now the loop to get the bounds and where to put them

  for (let x = nw.x; x <= se.x; x++) {
    for (let y = nw.y; y <= se.y; y++) {

      // TODO: there should be a better way to find bounds
      let nwBound = tile2LngLat({x: x, y: y, z: z, projection: obj.projection});
      let seBound = tile2LngLat({x: x+1, y: y+1, z: z, projection: obj.projection});

      // these are in lat/lng order, sigh
      let bounds = [[seBound.lat, nwBound.lng], [nwBound.lat, seBound.lng]];

      result.push({x: x, y: y, z: z, bounds: bounds});
    }
  }

  return result;
}

/**

Given a grid of longitude/latitude values, and a target point, determine the distance from each grid point to the target point. Input obj values:

lng, lat - the target point longitude and latitude

nlat, slat, wlng, elng - the grid boundaries

width, height - the number of longitudes and latitudes in the grid

TODO: computing great circle distance for a grid can be sped up a lot,
either by caching, or by noting there are formulas that make it easier

*/

function grid2Distances(obj) {

  let result = [];

  for (let j=0; j < obj.height; j++) {
    result[j] = [];
  for (let i=0; i < obj.width; i++) {

      // using 0.5 below chooses the center of each grid point
      let lat = obj.nlat - ((j+0.5)/obj.height)*(obj.nlat - obj.slat);
      let lng = obj.wlng + ((i+0.5)/obj.width)*(obj.elng - obj.wlng);
      result[j][i] = turf.distance([lng, lat], [obj.lng, obj.lat]);
    }
  }

  return result;
}

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
