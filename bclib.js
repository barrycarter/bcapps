/**

General notes:

lng = longitude (not lon or long)

z = zoom (not zoom)


*/


/** Apply function f to each value in hash hash */

function applyFunctionToHashValues(obj) {

  let returnHash = {};
  returnHash.hash = {};
    

  Object.keys(obj.hash).forEach(function (x) {
      returnHash.hash[x] = obj.f(obj.hash[x]);
    });

  return returnHash;

}  


/**

Bound a given number n by left and right

NOTE: not a hash to hash function

*/

function boundNumber(n, left, right) {

  if (n > right) {return right;}
  if (n < left) {return left;}
  return n;
  
}


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

/**

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

z: the current zoom level

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


  // TODO: the actual z value (but tile z value could be different)

  let z = obj.map.getZoom();

  let mapBounds = obj.map.getBounds();

  // compute min/max lat/lon truncating at limits

  // NOTE: this could be done better if we let lngLat2Tile() truncate

  let n = Math.max(Math.min(90, mapBounds.getNorth()), -90);
  let s = Math.max(Math.min(90, mapBounds.getSouth()), -90);
  let e = Math.min(Math.max(-180, mapBounds.getEast()), 180);
  let w = Math.min(Math.max(-180, mapBounds.getWest()), 180);

  // determine the x and y values corresponding to these extents (we
  // use 'floor' here because a tile starts at its nw boundary)

  // the corner boundaries (in this order so se > nw in both coords)

  // TODO: not happy with the way I am floor-ifying these

  let nw = applyFunctionToHashValues({hash: lngLat2Tile({z: z, lat: n, lng: w, projection: obj.projection}), f: Math.floor}).hash;
  let se = applyFunctionToHashValues({hash: lngLat2Tile({z: z, lat: s, lng: e, projection: obj.projection}), f: Math.floor}).hash;

  // and now the loop to get and place the tiles themselves

  for (let x = nw.x; x < se.x; x++) {
    for (let y = nw.y; y < se.y; y++) {

      // TODO: there should be a better way to find bounds

      let nwBound = tile2LngLat({x: x, y: y, z: z});
      let seBound = tile2LngLat({x: x+1, y: y+1, z: z});

      // these are in lat/lng order, sigh

      let bounds = [[seBound.lat, nwBound.lng], [nwBound.lat, seBound.lng]];

      // TODO: this is insanely specific to my test map, generalize
      let url = hack_beck2_tiles({z: z, x: x, y: y}).url;

      td([bounds, url], "BOUNDS/URL");

      L.imageOverlay(url, bounds, {opacity: obj.opacity}).addTo(obj.map);

    }
  }

}

/** transparent debugger */

function td(x, str) {
  console.log(`TD(${str}): `, JSON.stringify(x));
  return x;
}

