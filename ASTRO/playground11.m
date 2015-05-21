(*

Closed form formulas for some astronomical quantities.

The goal here is to find complicated-looking but easy-to-compute
formulas for people who want to "plug and chug"

I build up the formulas naturally, but give the end result as a
formula, not as a composition of formulas

All times in Unix days (per bclib.m)

All angles (including right ascension and declination and siderial
time) in radians

I will use precise numbers to avoid losing precision, but the
precision is generally unwarranted

These formulas strive for decent accuracy 1901-2099

*)

(*

In each case, I'll show the intermediate steps but enclose them as comments.

http://aa.usno.navy.mil/faq/docs/GAST.php

see also: http://aa.usno.navy.mil/publications/docs/Circular_163.pdf

gmst0[d_] = Rationalize[18.697374558+24.06570982441908*d,10^-100]

Convert Unix days to above (10957.5 = Unix day at 2000-01-01 12h UT)
and convert to radians

gmst[d_] = Simplify[Expand[gmst0[d-21915/2]/12*Pi]]

[results in bclib.m for gmst]

TODO: http://aa.usno.navy.mil/faq/docs/GAST.php (previous computation
may have been incorrect)

TODO: need to test formulas below

*)

obliquity[s_] = -(Pi*(-5063835528000 + s))/38880000000000

(*

RA and DEC to azimuth and altitude (does not correct for precession,
refraction)

http://idlastro.gsfc.nasa.gov/ftp/pro/astro/hadec2altaz.pro

sh = Sin[ha]
ch = Cos[ha]
sd = Sin[dec]
cd = Cos[dec]
sl = Sin[lat]
cl = Cos[lat]

x = - ch * cd * sl + sd * cl
y = - sh * cd
z = ch * cd * cl + sd * sl
r = Sqrt[x^2 + y^2]
; now get Alt, Az

http://en.wikipedia.org/wiki/Atan2 notes Mathematica oddness

az = ArcTan[x,y]
alt = ArcTan[r,z]

Simplifying conditions

conds = {-Pi/2<dec<Pi/2, -Pi/2<lat<Pi/2, 0<ra<2*Pi, -Pi<lon<Pi,
Element[s,Reals]}

radeclatlontime2az[ra_,dec_,lat_,lon_,s_] = az /. ha -> gmst[s]+lon-ra

radeclatlontime2el[ra_,dec_,lat_,lon_,s_] = alt /. ha -> gmst[s]+lon-ra

testing... Sirius = 6,45,50 and -16,44,08

ra = (6+45/60+50/3600)/12*Pi

dec = -(16+44/60+8/3600)/180*Pi

lat = (35+7/60+12/3600)/180*Pi

lon = -(106+37/60+12/3600)/180*Pi

s = 1431713169

N[radeclatlontime2az[ra,dec,lat,lon,1431713169]/Pi*180,20]

*)

radeclatlontime2az[ra_,dec_,lat_,lon_,s_] =

ArcTan[Cos[lat]*Sin[dec] + Cos[dec]*Sin[lat]*
   Sin[lon - ra + (Pi*(11366224765515 + 401095163740318*s))/200000000000000], 
 -(Cos[dec]*Cos[lon - ra + (Pi*(11366224765515 + 401095163740318*s))/
      200000000000000])]

radeclatlontime2el[ra_,dec_,lat_,lon_,s_] =

