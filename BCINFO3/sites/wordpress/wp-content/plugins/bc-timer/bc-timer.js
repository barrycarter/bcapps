// NOTE: I probably destroyed some cross-browser portability when
// creating/changing this, but I think it's legit JS the way it is

// NOTE: down to about 29 lines now

// we must parse largest units first, regardless of how they appear in format
function sortme(x,y) {
  if (secs[x.replace('%','')] > secs[y.replace('%','')]) {return(-1);}
  return(1);
}

function timer(el) {
  // Greogrian calendar has 365.2425 days/year excluding leap seconds
  // below roughly follows strftime format
  // lower case s below is really incorrect, but harmless
  var secs={S:1,s:1,M:60,H:3600,d:86400,U:604800,m:2629746,Y:31556952,C:3155695200};
  var units;

  // at one point, I tried to minimize the number of lines in this
  // plugin just to understand it; I'm now re-increasing them for
  // readability
  format = bctimer[el].getAttribute("format");
  time = bctimer[el].getAttribute("time");
  dir = bctimer[el].getAttribute("dir");
  now = new Date().getTime()/1000;
  sec = time - now;
  // TODO: this is bad bad bad, assumes you have timer in right direction
  sec = Math.abs(sec);

  // TODO: get below working
  //  if (dir=="1") {sec = -1*sec;}
  
 // replace %x with actual value (but with largest units first)
 var matches = format.match(/%./g);
 // matches.sort(sortme);

 for (i in matches) {
   j = matches[i].replace('%','');
   units = Math.floor(sec/secs[j]);
   sec = sec - secs[j]*units;
   format = format.replace(matches[i], units);
 }

 bctimer[el].innerHTML = format;

};

function start() {
  // removed a bunch of code here that older browsers may've needed re
  // document.getElementsByClassName == undefined
  bctimer = document.getElementsByClassName('bctimer');
  for (el in bctimer) {
    setInterval('timer('+el+')', 1000); }
}

window.onload = start;
