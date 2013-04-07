function trim(string) {
return string.replace(/^\s+/g,'').replace(/\s+$/g,''); } 

function timer(sec, format) {
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

 return(format);

};

function dhmstimer_decrease(el) {
var T = Math.round(((new Date()).getTime())/1000);
var S = dhmscountdown[el].id.substr(10) - T;
if (S <= 0) { window.location.reload(); }
dhmscountdown[el].innerHTML = timer(S, 'dhms'); }

function dhmstimer_increase(el) {
var T = Math.round(((new Date()).getTime())/1000);
var S = T - dhmscountup[el].id.substr(10);
dhmscountup[el].innerHTML = timer(S, 'dhms'); }

function clock_update(offset, form) {
var T = new Date();

if (offset == 'local') {
var H = T.getHours();
var m = T.getMinutes();
var s = T.getSeconds(); }

else {
var H = T.getUTCHours();
var m = T.getUTCMinutes();
var s = T.getUTCSeconds();

if (offset != 0) {
if (offset > 0) { offset = offset%24; }
else { offset = 24 - (-offset)%24; }

var S = (3600*(H + offset) + 60*m + s)%86400;
var H = Math.floor(S/3600);
var M = Math.floor(S/60);
var m = M - 60*H;
var s = S - 60*M; } }

if (H < 10) { H = '0'+H; }
if (m < 10) { m = '0'+m; }
if (s < 10) { s = '0'+s; }

switch (form) {
case 'hm': return H+':'+m; break;
case 'hms': return H+':'+m+':'+s; break;
default: return H+':'+m; } }


function hmclock_update(el) {
var offset = hmclock[el].id.substr(10);
hmclock[el].innerHTML = clock_update(offset, 'hm'); }

function hmsclock_update(el) {
var offset = hmsclock[el].id.substr(10);
hmsclock[el].innerHTML = clock_update(offset, 'hms'); }

function localhmclock_update(el) {
localhmclock[el].innerHTML = clock_update('local', 'hm'); }

function localhmsclock_update(el) {
localhmsclock[el].innerHTML = clock_update('local', 'hms'); }


function localyear_update(form) {
var T = new Date();
var year4 = T.getFullYear();
var year2 = (year4)%100;

switch (form) {
case '2': return year2;
case '4': return year4;
default: return year4; } }


function local2year_update(el) {
local2year[el].innerHTML = localyear_update('2'); }

function local4year_update(el) {
local4year[el].innerHTML = localyear_update('4'); }


function localisoyear_update(el) {
var T = new Date();
var isoyear = T.getFullYear();
var month = T.getMonth();
var monthday = T.getDate();
var weekday = T.getDay(); if (weekday == 0) { weekday = 7; }
if ((month == 0) && (weekday - monthday >= 4)) { isoyear = isoyear - 1; }
if ((month == 11) && (monthday - weekday >= 28)) { isoyear = isoyear + 1; }
localisoyear[el].innerHTML = isoyear; }


function localyearweek_update(el) {
var T = new Date();
var year = T.getFullYear();
var month = T.getMonth();
var monthday = T.getDate();
var weekday = T.getDay(); if (weekday == 0) { weekday = 7; }
var B = 0; if (((year%4 == 0) && (year%100 != 0)) || (year%400 == 0)) { B = 1; }
var array = new Array(0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);

if (month <= 1) { var N = 10 + array[month] + monthday - weekday; }
else { var N = B + 10 + array[month] + monthday - weekday; }
var yearweek = Math.floor(N/7);

if (yearweek == 0) {
B = 0; if ((((year - 1)%4 == 0) && ((year - 1)%100 != 0)) || ((year - 1)%400 == 0)) { B = 1; }
N = B + 375 + array[month] + monthday - weekday;
yearweek = Math.floor(N/7); }

if ((month == 11) && (monthday - weekday >= 28)) { yearweek = 1; }

localyearweek[el].innerHTML = yearweek; }


function localyearday_update(el) {
var T = new Date();
var year = T.getFullYear();
var month = T.getMonth();
var monthday = T.getDate();
var B = 0; if (((year%4 == 0) && (year%100 != 0)) || (year%400 == 0)) { B = 1; }
var array = new Array(0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);

if (month <= 1) { var yearday = array[month] + monthday; }
else { var yearday = B + array[month] + monthday; }

localyearday[el].innerHTML = yearday; }


function localmonth_update(form) {
var T = new Date();
var month1 = T.getMonth() + 1;
var month2 = month1;
if (month1 < 10) { month2 = '0'+month1; }
var month = stringmonth[month1].substr(0, 1)+stringmonth[month1].substr(1).toLowerCase();
var lowermonth = stringmonth[month1].toLowerCase();
var uppermonth = stringmonth[month1];

switch (form) {
case '1': return month1;
case '2': return month2;
case '': return month;
case 'lower': return lowermonth;
case 'upper': return uppermonth;
default: return month; } }


function localdefaultmonth_update(el) {
localmonth[el].innerHTML = localmonth_update(''); }

function local1month_update(el) {
local1month[el].innerHTML = localmonth_update('1'); }

function local2month_update(el) {
local2month[el].innerHTML = localmonth_update('2'); }

function locallowermonth_update(el) {
locallowermonth[el].innerHTML = localmonth_update('lower'); }

function localuppermonth_update(el) {
localuppermonth[el].innerHTML = localmonth_update('upper'); }


function localmonthday_update(form) {
var T = new Date();
var monthday1 = T.getDate();
var monthday2 = monthday1;
if (monthday1 < 10) { monthday2 = '0'+monthday1; }

switch (form) {
case '1': return monthday1;
case '2': return monthday2;
default: return monthday1; } }


function local1monthday_update(el) {
local1monthday[el].innerHTML = localmonthday_update('1'); }

function local2monthday_update(el) {
local2monthday[el].innerHTML = localmonthday_update('2'); }


function localweekday_update(form) {
var T = new Date();
var weekday1 = T.getDay();
var weekday = stringweekday[weekday1].substr(0, 1)+stringweekday[weekday1].substr(1).toLowerCase();
var lowerweekday = stringweekday[weekday1].toLowerCase();
var upperweekday = stringweekday[weekday1];

switch (form) {
case '': return weekday;
case 'lower': return lowerweekday;
case 'upper': return upperweekday;
default: return weekday; } }


function localdefaultweekday_update(el) {
localweekday[el].innerHTML = localweekday_update(''); }

function locallowerweekday_update(el) {
locallowerweekday[el].innerHTML = localweekday_update('lower'); }

function localupperweekday_update(el) {
localupperweekday[el].innerHTML = localweekday_update('upper'); }


function localtimezone_update(el) {
var offset = -((new Date()).getTimezoneOffset())/60;
if (offset == 0) { var timezone = 'UTC'; }
if (offset > 0) { var timezone = 'UTC+'+offset; }
if (offset < 0) { var timezone = 'UTC'+offset; }
localtimezone[el].innerHTML = timezone; }


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
dhmcountdown = document.getElementsByClassName('dhmcountdown');
for (el in dhmcountdown) { if (parseInt(el) + 1) { setInterval('dhmtimer_decrease('+el+')', 1000); } }
dhcountdown = document.getElementsByClassName('dhcountdown');
for (el in dhcountdown) { if (parseInt(el) + 1) { setInterval('dhtimer_decrease('+el+')', 1000); } }
dcountdown = document.getElementsByClassName('dcountdown');
for (el in dcountdown) { if (parseInt(el) + 1) { setInterval('dtimer_decrease('+el+')', 1000); } }
hmscountdown = document.getElementsByClassName('hmscountdown');
for (el in hmscountdown) { if (parseInt(el) + 1) { setInterval('hmstimer_decrease('+el+')', 1000); } }
hmcountdown = document.getElementsByClassName('hmcountdown');
for (el in hmcountdown) { if (parseInt(el) + 1) { setInterval('hmtimer_decrease('+el+')', 1000); } }
hcountdown = document.getElementsByClassName('hcountdown');
for (el in hcountdown) { if (parseInt(el) + 1) { setInterval('htimer_decrease('+el+')', 1000); } }
mscountdown = document.getElementsByClassName('mscountdown');
for (el in mscountdown) { if (parseInt(el) + 1) { setInterval('mstimer_decrease('+el+')', 1000); } }
mcountdown = document.getElementsByClassName('mcountdown');
for (el in mcountdown) { if (parseInt(el) + 1) { setInterval('mtimer_decrease('+el+')', 1000); } }
scountdown = document.getElementsByClassName('scountdown');
for (el in scountdown) { if (parseInt(el) + 1) { setInterval('stimer_decrease('+el+')', 1000); } }
hmsrcountdown = document.getElementsByClassName('hmsrcountdown');
for (el in hmsrcountdown) { if (parseInt(el) + 1) { setInterval('hmsrtimer_decrease('+el+')', 1000); } }
hmrcountdown = document.getElementsByClassName('hmrcountdown');
for (el in hmrcountdown) { if (parseInt(el) + 1) { setInterval('hmrtimer_decrease('+el+')', 1000); } }
hrcountdown = document.getElementsByClassName('hrcountdown');
for (el in hrcountdown) { if (parseInt(el) + 1) { setInterval('hrtimer_decrease('+el+')', 1000); } }
msrcountdown = document.getElementsByClassName('msrcountdown');
for (el in msrcountdown) { if (parseInt(el) + 1) { setInterval('msrtimer_decrease('+el+')', 1000); } }
mrcountdown = document.getElementsByClassName('mrcountdown');
for (el in mrcountdown) { if (parseInt(el) + 1) { setInterval('mrtimer_decrease('+el+')', 1000); } }
srcountdown = document.getElementsByClassName('srcountdown');
for (el in srcountdown) { if (parseInt(el) + 1) { setInterval('srtimer_decrease('+el+')', 1000); } }
dhmscountup = document.getElementsByClassName('dhmscountup');
for (el in dhmscountup) { if (parseInt(el) + 1) { setInterval('dhmstimer_increase('+el+')', 1000); } }
dhmcountup = document.getElementsByClassName('dhmcountup');
for (el in dhmcountup) { if (parseInt(el) + 1) { setInterval('dhmtimer_increase('+el+')', 1000); } }
dhcountup = document.getElementsByClassName('dhcountup');
for (el in dhcountup) { if (parseInt(el) + 1) { setInterval('dhtimer_increase('+el+')', 1000); } }
dcountup = document.getElementsByClassName('dcountup');
for (el in dcountup) { if (parseInt(el) + 1) { setInterval('dtimer_increase('+el+')', 1000); } }
hmscountup = document.getElementsByClassName('hmscountup');
for (el in hmscountup) { if (parseInt(el) + 1) { setInterval('hmstimer_increase('+el+')', 1000); } }
hmcountup = document.getElementsByClassName('hmcountup');
for (el in hmcountup) { if (parseInt(el) + 1) { setInterval('hmtimer_increase('+el+')', 1000); } }
hcountup = document.getElementsByClassName('hcountup');
for (el in hcountup) { if (parseInt(el) + 1) { setInterval('htimer_increase('+el+')', 1000); } }
mscountup = document.getElementsByClassName('mscountup');
for (el in mscountup) { if (parseInt(el) + 1) { setInterval('mstimer_increase('+el+')', 1000); } }
mcountup = document.getElementsByClassName('mcountup');
for (el in mcountup) { if (parseInt(el) + 1) { setInterval('mtimer_increase('+el+')', 1000); } }
scountup = document.getElementsByClassName('scountup');
for (el in scountup) { if (parseInt(el) + 1) { setInterval('stimer_increase('+el+')', 1000); } }
hmsrcountup = document.getElementsByClassName('hmsrcountup');
for (el in hmsrcountup) { if (parseInt(el) + 1) { setInterval('hmsrtimer_increase('+el+')', 1000); } }
hmrcountup = document.getElementsByClassName('hmrcountup');
for (el in hmrcountup) { if (parseInt(el) + 1) { setInterval('hmrtimer_increase('+el+')', 1000); } }
hrcountup = document.getElementsByClassName('hrcountup');
for (el in hrcountup) { if (parseInt(el) + 1) { setInterval('hrtimer_increase('+el+')', 1000); } }
msrcountup = document.getElementsByClassName('msrcountup');
for (el in msrcountup) { if (parseInt(el) + 1) { setInterval('msrtimer_increase('+el+')', 1000); } }
mrcountup = document.getElementsByClassName('mrcountup');
for (el in mrcountup) { if (parseInt(el) + 1) { setInterval('mrtimer_increase('+el+')', 1000); } }
srcountup = document.getElementsByClassName('srcountup');
for (el in srcountup) { if (parseInt(el) + 1) { setInterval('srtimer_increase('+el+')', 1000); } }
hmclock = document.getElementsByClassName('hmclock');
for (el in hmclock) { if (parseInt(el) + 1) { setInterval('hmclock_update('+el+')', 1000); } }
hmsclock = document.getElementsByClassName('hmsclock');
for (el in hmsclock) { if (parseInt(el) + 1) { setInterval('hmsclock_update('+el+')', 1000); } }
localhmclock = document.getElementsByClassName('localhmclock');
for (el in localhmclock) { if (parseInt(el) + 1) { setInterval('localhmclock_update('+el+')', 1000); } }
localhmsclock = document.getElementsByClassName('localhmsclock');
for (el in localhmsclock) { if (parseInt(el) + 1) { setInterval('localhmsclock_update('+el+')', 1000); } }
local2year = document.getElementsByClassName('local2year');
for (el in local2year) { if (parseInt(el) + 1) { setInterval('local2year_update('+el+')', 1000); } }
local4year = document.getElementsByClassName('local4year');
for (el in local4year) { if (parseInt(el) + 1) { setInterval('local4year_update('+el+')', 1000); } }
localisoyear = document.getElementsByClassName('localisoyear');
for (el in localisoyear) { if (parseInt(el) + 1) { setInterval('localisoyear_update('+el+')', 1000); } }
localyearweek = document.getElementsByClassName('localyearweek');
for (el in localyearweek) { if (parseInt(el) + 1) { setInterval('localyearweek_update('+el+')', 1000); } }
localyearday = document.getElementsByClassName('localyearday');
for (el in localyearday) { if (parseInt(el) + 1) { setInterval('localyearday_update('+el+')', 1000); } }
localmonth = document.getElementsByClassName('localmonth');
for (el in localmonth) { if (parseInt(el) + 1) { setInterval('localdefaultmonth_update('+el+')', 1000); } }
local1month = document.getElementsByClassName('local1month');
for (el in local1month) { if (parseInt(el) + 1) { setInterval('local1month_update('+el+')', 1000); } }
local2month = document.getElementsByClassName('local2month');
for (el in local2month) { if (parseInt(el) + 1) { setInterval('local2month_update('+el+')', 1000); } }
locallowermonth = document.getElementsByClassName('locallowermonth');
for (el in locallowermonth) { if (parseInt(el) + 1) { setInterval('locallowermonth_update('+el+')', 1000); } }
localuppermonth = document.getElementsByClassName('localuppermonth');
for (el in localuppermonth) { if (parseInt(el) + 1) { setInterval('localuppermonth_update('+el+')', 1000); } }
local1monthday = document.getElementsByClassName('local1monthday');
for (el in local1monthday) { if (parseInt(el) + 1) { setInterval('local1monthday_update('+el+')', 1000); } }
local2monthday = document.getElementsByClassName('local2monthday');
for (el in local2monthday) { if (parseInt(el) + 1) { setInterval('local2monthday_update('+el+')', 1000); } }
localweekday = document.getElementsByClassName('localweekday');
for (el in localweekday) { if (parseInt(el) + 1) { setInterval('localdefaultweekday_update('+el+')', 1000); } }
locallowerweekday = document.getElementsByClassName('locallowerweekday');
for (el in locallowerweekday) { if (parseInt(el) + 1) { setInterval('locallowerweekday_update('+el+')', 1000); } }
localupperweekday = document.getElementsByClassName('localupperweekday');
for (el in localupperweekday) { if (parseInt(el) + 1) { setInterval('localupperweekday_update('+el+')', 1000); } }
localtimezone = document.getElementsByClassName('localtimezone');
for (el in localtimezone) { if (parseInt(el) + 1) { setInterval('localtimezone_update('+el+')', 1000); } } }


if (typeof(document.addEventListener) == 'function') {
document.addEventListener('DOMContentLoaded', start, false); }
else { window.onload = start; }
