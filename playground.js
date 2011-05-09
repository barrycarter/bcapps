/* Given number of seconds, compute years, months, days, etc */
function timer(sec, format) {
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
   print("SECBEFORE:"+sec);
   sec = sec - secs[j]*units;
   print("UNITS:"+units);
   print("SIZE:"+secs[j]);
   print("SECAFTER:"+sec);
   format = format.replace(matches[i], units);
 }

 return(format);

};

// same tests as perl

d = new Date();
print(timer(d.getTime()/1000, '%Y years, %m months, %d days, %H hours, %M minutes, %S seconds'));
