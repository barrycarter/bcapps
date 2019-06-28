/**

General notes:

lng = longitude (do not use lon or long as var names)

z = zoom (do not use zoom as a var name)

obj = hash passed in (do not use hash as a var name)


*/

// TODO: just realized I'm mixing radians and degrees, which is bad


// TODO: find a better way to store this constant as a lib constant

bclib = {};
bclib.MERCATOR_LAT_LIMIT = 85.0511;

// taken directly from
// https://stackoverflow.com/questions/4467539/javascript-modulo-gives-a-negative-result-for-negative-numbers
// (possibly a bad idea)

Number.prototype.mod = function(n) {return ((this%n)+n)%n;}

/**

Replace templated variables in string s with object objs values 

TODO: seriously consider keeping my "all functions take one object"
oath stronger


*/

function convertStringTemplate(s, obj) {

  s = s.replace(/\$\{(.+?)\}/g, function(x, m1) {return obj[m1]});

  // TODO: figure out why below and variants don't work
  //  s = s.replace(/\$\{(.+?)\}/g, obj.$1);

  return s;
}

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

NOTE: This subroutine assumes original image was sliced using:

gdal_translate -of vrt -expand rgba original_image temp.vrt
gdal2tiles.py -z 0-10 -p raster -v temp.vrt

or similar. Tiles created using other methods should not use this subroutine.

Does what tile2LngLat for images that have been sliced up. Input hash values:

z: tile zoom value (0 = highest resolution per gdal_retile.py)
x: tile x value (may be fractional)
y: tile y value (may be fractional)
width: image width
height: image height
origTileZoom: the original tiles are at this zoom level

*/

function imageTile2LngLat(obj) {

  return {
  lng: obj.x*256/obj.width*2**(obj.origTileZoom-obj.z)*360-180,
      lat: obj.y*256/obj.height*2**(obj.origTileZoom-obj.z)*180-90
      };
}

/*

NOTE: This subroutine assumes original image was sliced using:

gdal_translate -of vrt -expand rgba original_image temp.vrt
gdal2tiles.py -z 0-10 -p raster -v temp.vrt

or similar. Tiles created using other methods should not use this subroutine.

Does what lngLat2Tile for images that have been sliced up. Input hash values:

z: tile zoom value (0 = highest resolution per gdal_retile.py)
lng: longitude
lat: latitude
width: image width
height: image height
origTileZoom: the original tiles are at this zoom level

*/


function lngLat2ImageTile(obj) {

  // compute the highest value of x to allow toroidal tiling

  let zoomMultiplier = 2**(obj.z-obj.origTileZoom-8);

  return {
  x: (obj.lng+180)/360*obj.width*zoomMultiplier,
    y: (obj.lat+90)/180*obj.height/256*2**(obj.z-obj.origTileZoom)
	};
}


/**

Given a range of latitude and longitude, and an image broken up into
tiles, return where to place which pieces of the image.

This routine is slightly more efficient and flexible than calling
lngLat2ImageTile multiple times: it allows longitudes and latitudes
outside normal limits and makes some calculations only once.

The passed object should have:

bounds: [[slat, wlon], [nlat, elon]]
tileURL: the template for the URLs for the image
width: the image width
height: the image height
z: the zoom level

*/

function lngLatRange2ImageTiles(obj) {

  // TODO: in reality, we get this from passed obj

  let lngRange = [-180, -90];
  let latRange = [-90, 0];
  let z = 5;
  let origTileZoom = 8;
  let width = 43200;
  let height = 21600;

}

/**

Converts a slippy tile or an equirectangular tile to a latitude and longitude:

z: tile zoom value
x: tile x value (may be fractional)
y: tile y value (may be fractional)

projection: if 1 or "mercator", Mercator project, otherwise
equirectangular project

*/

function tile2LngLat(obj) {

  // set defaults

  obj = mergeHashes(obj, str2hash("projection=0"));

  // use mercator instead of 1 in future
  if (obj.projection == "mercator") {obj.projection = 1;}

  // true for both projections

  obj.lng = obj.x/2**obj.z*360-180;
  obj.wlng = Math.floor(obj.x)/2**obj.z*360-180;
  obj.elng = Math.floor(obj.x+1)/2**obj.z*360-180;

  if (obj.projection == 0) {
    obj.lat = 90-obj.y/2**obj.z*180;
    obj.nlat = 90-Math.floor(obj.y)/2**obj.z*180;
    obj.slat = 90-Math.floor(obj.y+1)/2**obj.z*180;
  } else {

    // for Mercator (http://mathworld.wolfram.com/MercatorProjection.html)
    // TODO: this is hideous
    obj.lat = 180/Math.PI*(Math.PI/2-2*Math.atan(Math.exp((obj.y/2**obj.z-1/2)*2*Math.PI)));
    obj.nlat = 180/Math.PI*(Math.PI/2-2*Math.atan(Math.exp((Math.floor(obj.y)/2**obj.z-1/2)*2*Math.PI)));
    obj.slat = 180/Math.PI*(Math.PI/2-2*Math.atan(Math.exp((Math.floor(obj.y+1)/2**obj.z-1/2)*2*Math.PI)));
  }

    return obj;

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
  obj.x = (obj.lng+180)/360*2**obj.z;

  let y = 0;

  // for equirectangular
  if (obj.projection == 0) {

    if (obj.lat < -90) {
      obj.y = 2**obj.z-1;
      obj.err = "Input latitude less than -90, returning value for -90";
    } else if (obj.lat > 90) {
      obj.y = 0;
      obj.err = "Input latitude greater than +90, returning value for +90";
    } else {
    // TODO: cleanup this code, maybe no ternary operator below
    // special case: -90 itself touches 2**obj.z which it shouldn't
      obj.y = (90-obj.lat)/180*2**obj.z;
    }

  } else {

    // TODO: I copied this from somewhere else and am NOT happy about it
    // for Mercator (http://mathworld.wolfram.com/MercatorProjection.html)

      if (obj.lat < -bclib.MERCATOR_LAT_LIMIT) {
	obj.y = 2**obj.z-1;
	obj.err = "Input latitude less than ~-85, returning value for ~-85";
      } else if (obj.lat > bclib.MERCATOR_LAT_LIMIT) {
	obj.y = 0;
	obj.err = "Input latitude greater than ~+85, returning value for ~+85";
      } else {
	let lat_rad = obj.lat/180*Math.PI;
	obj.y = 2**obj.z*(-Math.log(Math.tan(lat_rad) + 1/Math.cos(lat_rad))/2/Math.PI+1/2);
      }
  }
  return obj;
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

opacity: tile opacity

fake: if set to 1, don't do anything, just print out debugging info

*/

function placeTilesOnMap(obj) {

  obj = mergeHashes(obj, str2hash("minZoom=0&maxZoom=999&projection=0&opacity=1"));

  if (obj.fake) {return;}


  // TODO: the actual z value (but tile z value could be different)

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

  //  td([z, nw.x, se.x, nw.y, se.y], "XY FOR");

  // and now the loop to get and place the tiles themselves

  for (let x = nw.x; x <= se.x; x++) {
    for (let y = nw.y; y <= se.y; y++) {

      // TODO: there should be a better way to find bounds

      let nwBound = tile2LngLat({x: x, y: y, z: z, projection: obj.projection});
      let seBound = tile2LngLat({x: x+1, y: y+1, z: z, projection: obj.projection});

      // these are in lat/lng order, sigh

      let bounds = [[seBound.lat, nwBound.lng], [nwBound.lat, seBound.lng]];

      //      let bounds = [[seBound.lat, seBound.lng], [nwBound.lat, nwBound.lng]];

      // if bounded, don't print out of bound tiles
      // TODO: allow wraparound

      if (x < 0 || x >= 2**z || y < 0 || y >= 2**z) {continue;}

      // determine URL from template sent (TODO: not working quite right)

      let url = convertStringTemplate(obj.tileURL, {x: x, y: y, z: z});

      //      console.log(`Bounds ${bounds}, tile: ${url}`);

      // TODO: this is insanely specific to my test map, generalize
      //      let url = hack_beck2_tiles({z: z, x: x, y: y}).url;
      
      //      td([bounds, url], "BOUNDS/URL");

      // TESTING caching

      //      L.imageOverlay(url, bounds, {opacity: obj.opacity}).addTo(obj.map);
      L.imageOverlay(URLCache.get(url), bounds, {opacity: obj.opacity}).addTo(obj.map);

    }
  }
}

/** transparent debugger */

function td(x, str) {
  console.log(`TD(${str}): `, JSON.stringify(x, getCircularReplacer()));
  return x;
}

// TODO: move functions that aren't mine somewhere else?

/** Cut and paste from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Errors/Cyclic_object_value#Examples */

const getCircularReplacer = () => {

      const seen = new WeakSet();
      return (key, value) => {
	if (typeof value === "object" && value !== null) {
	  if (seen.has(value)) {
	    return;
	  }
	  seen.add(value);
	}
	return value;
      };
    };
