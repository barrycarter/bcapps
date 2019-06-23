
// window.requestAnimationFrame(f);

let width = 1400;
let height = 700;

c = document.getElementById("dots");
ctx = c.getContext("2d");

// create some repeatable random numbers

Srand.seed(20190623);

console.log(Srand.random());
console.log(Srand.random());
console.log(Srand.random());
console.log(Srand.random());

// create just 10K random points

let stars = [];

for (let i=0; i < 10000; i++) {

  // TODO: add "relative brightness"
  star = {x: Srand.random()-1/2, y: Srand.random()-1/2, z: Srand.random()-1/2,
          r: Math.floor(Srand.random()*256), g: Math.floor(Srand.random()*256),
          b: Math.floor(Srand.random()*256)};

  stars.push(star);
}

console.log(stars);

// draw the stars

f();

function f() {

  for (let i=0; i < stars.length; i++) {

    let pos = xyz2sph(stars[i]);

    // and the x and y position

    // ignore off screen theta
    if (pos.th < -Math.PI || pos.th > Math.PI) {continue;}

    let x = (Math.cos(pos.ph)*pos.th/Math.PI/2 + 1/2)*width;
    let y = pos.ph/Math.PI*height + height/2;

    ctx.fillRect(x,y,1,1);

    //    console.log("POS", pos);

  }

}
