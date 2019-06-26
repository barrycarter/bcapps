
// window.requestAnimationFrame(f);

let width = 1400;
let height = 700;

c = document.getElementById("dots");
ctx = c.getContext("2d");

// real stars

function draw_stars() {


  


}


  die_or_live();

// create some repeatable random numbers

Srand.seed(20190623);

console.log(Srand.random());
console.log(Srand.random());
console.log(Srand.random());
console.log(Srand.random());

// create just 10K random points

let stars = [];

for (let i=0; i < 50000; i++) {

  // TODO: add "relative brightness"
  star = {x: Srand.random()-1/2, y: Srand.random()-1/2, z: Srand.random()-1/2,
          r: Math.floor(Srand.random()*256), g: Math.floor(Srand.random()*256),
          b: Math.floor(Srand.random()*256), 
          sz: 1+Math.floor(Srand.random()*5)};

  //  console.log(star);

  stars.push(star);
}

// console.log(stars);

// draw the stars

setInterval(f, 10);

function f() {

  console.log("F CALLED");

  ctx.clearRect(0, 0, width, height);

  for (let i=0; i < stars.length; i++) {

    let pos = xyz2sph(stars[i]);

    // and the x and y position

    // ignore off screen theta
    if (pos.th < -Math.PI || pos.th > Math.PI) {continue;}

    let x = (Math.cos(pos.ph)*pos.th/Math.PI/2 + 1/2)*width;
    let y = pos.ph/Math.PI*height + height/2;

    ctx.fillStyle = '#ff0000';
    ctx.fillRect(x,y, stars[i].sz, stars[i].sz);

    stars[i].x -= 0.001;
    stars[i].y -= 0.001;
  }

  //    requestAnimationFrame(f);

    //    console.log("POS", pos.size);
}
