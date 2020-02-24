let button = document.getElementById('button');
button.onclick = dostuff;

let output = document.getElementById('output');

function dostuff(e) {

let ra = document.getElementById('ra').value/12*Math.PI;
let dec = document.getElementById('dec').value/180*Math.PI;
let lat = document.getElementById('lat').value/180*Math.PI;

let res = findHeliacalDate({ra: ra, dec: dec, lat: lat});

let str = "";

if (res.error === 'circumpolar') {
  str = "Star never sets";
} else if (res.error === 'anticircumpolar') {
  str = "Star never rises";
} else {
  str = `
  Star rises at dawn: ${res["twilight,starhorizon,rise"]}<br>
  Star rises with Sun: ${res["sunhorizon,starhorizon,rise"]}<br>
  Star sets with Sun: ${res["sunhorizon,starhorizon,set"]}<br>
  Star sets at dusk: ${res["twilight,starhorizon,set"]}
`;
}

output.innerHTML = str;

}