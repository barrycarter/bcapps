function timer(sec) {

  //  sec=dhmscountdown[el].id.substr(10)-Math.round(((new Date()).getTime())/1000);

  /* hardcoding for now - BC */
 format = "%Y years, %m months, %U weeks, %d days, %H hours, %M minutes, %S seconds";
  /* ported from Perl */
 var secs = {};
 secs['S'] = 1; 
 secs['M'] = 60; 
 secs['H'] = 3600; 
 secs['d'] = 86400;
 secs['U'] = 604800;
 secs['m'] = 2629746;
 secs['Y'] = 31556952;
 secs['C'] = 3155695200;

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

 dhmscountdown[el].innerHTML = format;
 
 return(format);

};

function dhmstimer_decrease(el) {
var T = Math.round(((new Date()).getTime())/1000);
var S = dhmscountdown[el].id.substr(10) - T;
if (S <= 0) { window.location.reload(); }
dhmscountdown[el].innerHTML = timer(S); }

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

dhmscountdown = document.getElementsByClassName('dhmscountdown');
for (el in dhmscountdown) { if (parseInt(el) + 1) { setInterval('dhmstimer_decrease('+el+')', 1000); } }

}

if (typeof(document.addEventListener) == 'function') {
document.addEventListener('DOMContentLoaded', start, false); }
else { window.onload = start; }
