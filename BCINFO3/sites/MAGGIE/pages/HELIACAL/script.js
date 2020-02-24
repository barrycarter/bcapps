let field = [];

let fields = ['city', 'star', 'ra', 'dec', 'lat', 'lng'];

for (i in fields) {
  field[fields[i]] = document.getElementById(fields[i]);
}

$('#star').autocomplete({
source: Object.keys(stars), minLength: 3, close: updateStar});

$('#city').autocomplete({
source: Object.keys(cities), minLength: 3, close: updateCity});

function updateCity(e) {

let city = field['city'].value;

if (!(city in cities)) {return;}

field['lat'].value = cities[city].lat;
field['lng'].value = cities[city].lng;
}

function updateStar(e) {

let star = field['star'].value;

if (!(star in stars)) {return;}

field['ra'].value = stars[star].ra/15;
field['dec'].value = stars[star].dec;
}

function sunInfo({ d, lat, alt = 0 }) {

  // sun ra and dec on day d of year, day 0 = start of year

  // unix second of dth day in 2020
  let sec = 1577836800 + d * 86400;

  let ra = interpX2Y({ interp: solarRAInterp, x: sec, div: 1000000 }).y;

  let dec = interpX2Y({ interp: solarDecInterp, x: sec, div: 1000000 }).y;

  return starInfo({ ra: ra, dec: dec, lat: lat, alt: alt })
}

function starInfo({ ra, dec, lat, alt = 0 }) {

  let acos = Math.acos;
  let cos = Math.cos;
  let sin = Math.sin;
  let tan = Math.tan;

  // thing we are taking acos of

  let cosVal = sin(alt) / cos(dec) / cos(lat) - tan(dec) * tan(lat);

  if (Math.abs(cosVal) > 1) {
    console.log(`ERROR: abs(${cosVal}) > 1`);
    return { error: "invalid trig" };
  }
  let uptime = (acos(cosVal));

  return { noon: ra, rise: ra - uptime, set: ra + uptime, uptime: 2 * uptime };

  /*
  return { noon: (ra + 2*Math.PI)%(2*Math.PI), 
  rise: (ra - uptime + 2*Math.PI)%(2*Math.PI), 
  set: (ra + uptime + 2*Math.PI)%(2*Math.PI), 
  uptime: 2 * uptime };
  */

}

function binSearch({ f, a, b }) {

  //  console.log(`BINSEARCH: ${a}, ${b}, ${f(a)}, ${f(b)}`);

  if (Math.sign(f(a)) == Math.sign(f(b))) {
    console.log(`BAD BINARY SEARCH: ${a}, ${b}, ${f(a)}, ${f(b)}`);
    return "BAD BINARY SEARCH";
  }

  let mid = (a + b) / 2;
  let fmid = f(mid);

  if (Math.abs(a - b) < 10 ** -6) { return mid; }

  if (fmid == undefined) {
    return "BAD BINARY SEARCH";
  }

  //  console.log(`f: ${f(a)} ${f(b)} ${f(mid)}`);

  if (Math.abs(fmid) < 10 ** -6) { return mid; }

  if (Math.sign(f(a)) == Math.sign(fmid)) {
    return binSearch({ f: f, a: mid, b: b });
  } else {
    return binSearch({ f: f, a: a, b: mid });
  }
}

function findHeliacalDate({ ra, dec, lat }) {

  // check for circumpolarity or opposite

  if (Math.abs(dec + lat) > Math.PI / 2 - 34 / 60 / 180 * Math.PI) { return { error: 'circumpolar' } }

  if (Math.abs(dec - lat) > Math.PI / 2 - 34 / 60 / 180 * Math.PI) { return { error: 'anticircumpolar' } }

  let res = {};

  let sunAlts = { twilight: -6, sunhorizon: -50 / 60 };
  let starAlts = { starhorizon: -34 / 60 };
  let timeDay = { rise: "rise", set: "set" };


  for (k1 in sunAlts) {
    for (k2 in starAlts) {
      for (k3 in timeDay) {

        let sunAlt = sunAlts[k1] / 180 * Math.PI;
        let starAlt = starAlts[k2] / 180 * Math.PI;
        let star = starInfo({ ra: ra, dec: dec, lat: lat, alt: starAlt });

        //console.log("DELTA", `${k1}, ${k2}, ${k3}`);
        //        console.log("BETA", sunInfo({lat: lat, d:0, alt: sunAlt}));
        //        console.log("GAMMA", star);

        let f = function (d) {
          return sunInfo({ lat: lat, d: d, alt: sunAlt })[timeDay[k3]] - star[timeDay[k3]]
        };

      // g will be f plus a consant

      let c = 0;

      if (f(0) > 0) {
        c = -2*Math.PI*Math.ceil(f(0)/2/Math.PI);
      }

      if (f(366) < 0) {
        c = 2*Math.PI*Math.ceil(-f(366)/2/Math.PI)
      }


        let g = function (d) {return f(d) + c};

        let temp2 = binSearch({ f: g, a: 0, b: 366 });

        //        console.log(`BIN: ${temp2}`);

        let date = new Date();

        // first day of 2020
        date.setTime(1577836800*1000 + temp2 * 86400000);


        res[`${k1},${k2},${k3}`] = date.toLocaleDateString("en-US", { month: "short", day: "numeric" })

        // console.log("DATE", res[`${k1},${k2},${k3}`]);

      }
    }
  }
  return res;
}

// TODO: list of stars maybe w/ autocomplete

