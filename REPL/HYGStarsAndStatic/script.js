var i=0;
window.requestAnimationFrame(f);

c = document.getElementById("dots");
ctx = c.getContext("2d");

function f() {

  ctx.clearRect(0,0,1600,900);


  for (i=0; i<=240000; i++) {
    x = Math.floor(Math.random()*1600);
    y = Math.floor(Math.random()*900);
    ctx.fillRect(x,y,1,1);
  }
  requestAnimationFrame(f);
}
