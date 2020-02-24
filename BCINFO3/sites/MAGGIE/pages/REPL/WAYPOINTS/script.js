let a = faa['01818.32*H'];
let b = faa['50598.*A'];

let button = document.getElementById('run');
button.onclick = update;

let inputs = ['n', 'lng1', 'lng2', 'lat1', 'lat2'];

let divtag = document.getElementById('results');

let elts = {};

inputs.map((x) => elts[x] = document.getElementById(x));

// console.log(var_dump(button));

function update(event) {

  let str = '<table border>\n<tr><th>#</th><th>ID</th><th>Name</th><th>Waypoint Pos\n(lng, lat)</th><th>Station Pos\n(lng, lat)</th><th>Distance (miles)</th></tr>';

  let obj = {};

inputs.map((x) => obj[x] = elts[x].value);
obj.unit = 'degrees';

let res = waypoints(obj).arr;

// res.arr = res.arr.map((x) => {return [x[0]*bclib.Degree, x[1]*bclib.Degree]});

console.log(`RES: ${res}`);


let keys = Object.keys(faa);

for (let i=0; i < res.length; i++) {

  let closest = "";
  let min = +Infinity;

  for (let j=0; j < keys.length; j++) {
    let gcd = turf.distance(res[i], [faa[keys[j]].lng, faa[keys[j]].lat], {unit: 'miles'});

    if (gcd < min) {
      min = gcd;
      closest = keys[j];
    }
  }



  // TODO: find a better way to do this, not * -1
  let pslng = (faa[closest].lng*1.).toFixed(4);
  let pslat = (faa[closest].lat*1.).toFixed(4);

  str += `<tr>
  <td>${i}</td>
  <td>${closest}</td>
  <td>${faa[closest].name}</td>
  <td>${res[i][0].toFixed(4)}, ${res[i][1].toFixed(4)}</td>
  <td>${pslng}, ${pslat}</td>
  <td>${min.toFixed(2)}</td>
  </tr>\n`;
//    console.log(i, closest, min, faa[keys[closest]].FacilityName);
//  console.log(obj);

//  console.log(event);
}

str += "</table>\n";

divtag.innerHTML = str;
// console.log(str);

}
