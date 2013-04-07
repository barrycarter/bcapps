// Greogrian calendar has 365.2425 days/year excluding leap seconds
// below roughly follows strftime format
var secs={S:1,M:60,H:3600,d:86400,U:604800,m:2629746,Y:31556952,C:3155695200};

function timer(el) {

  // seconds to event
  // TODO: get substr() working so I can have multiple timers with same date
  sec=bctimer[el].id-Math.round(((new Date()).getTime())/1000);

  /* hardcoding for now - BC */
 format = "%Y years, %m months, %U weeks, %d days, %H hours, %M minutes, %S seconds";
  /* ported from Perl */

 function sortme(x,y) {
   if (secs[x.replace('%','')] > secs[y.replace('%','')]) {return(-1);}
   return(1);
 }

 var matches = format.match(/%./g);
 matches.sort(sortme);

 for (i in matches) {
   j = matches[i].replace('%','');
   var units = Math.floor(sec/secs[j]);
   sec = sec - secs[j]*units;
   format = format.replace(matches[i], units);
 }

 bctimer[el].innerHTML = format;

};

function start() {
if (document.getElementsByClassName == undefined) {
document.getElementsByClassName = function(className) {
var hasClassName = new RegExp('(?:^|\\s)' + className + '(?:$|\\s)');
var allElements = document.getElementsByTagName('*');
var results = [];
var element;
for (i = 0; (element = allElements[i]) != null; i++) {
var elementClass = element.className;
if (elementClass && elementClass.indexOf(className) != -1 && hasClassName.test(elementClass)) {
results.push(element); } }
return results; } }

bctimer = document.getElementsByClassName('bctimer');
for (el in bctimer) {setInterval('timer('+el+')', 1000); }

}

if (typeof(document.addEventListener) == 'function') {
document.addEventListener('DOMContentLoaded', start, false); }
else { window.onload = start; }
