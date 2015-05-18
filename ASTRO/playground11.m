(*

Closed form formulas for some astronomical quantities.

The goal here is to find complicated-looking but easy-to-compute
formulas for people who want to "plug and chug"

I build up the formulas naturally, but give the end result as a
formula, not as a composition of formulas

All times in Unix seconds

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

Convert Unix seconds to above (946728000 = Unix time at 2000-01-01 12h UT)

temp0[s_] = (s-946728000)/86400

and convert to radians

gmst[s_] = Expand[gmst0[temp0[s]]/12*Pi]

yielding...:

*)

gmst[s_] = (-452506800334363673497*Pi)/20593349747540136 +
(424749743*Pi*s)/18299087654400

(*

also from http://aa.usno.navy.mil/faq/docs/GAST.php

e0[d_] = Rationalize[23.4393 - 0.0000004*d,10^-100]*Degree

l0[d_] = Rationalize[280.47 + 0.98565*d,10^-100]*Degree

omega0[d_] = Rationalize[125.04 - 0.052954*d,10^-100]*Degree

deltapsi0[d_]= Rationalize[
 -0.000319*Sin[omega0[d]]-0.000024*Sin[2*l0[d]],10^-100]

eqeq0[d_] = Rationalize[deltapsi0[d]*Cos[e0[d]],10^-100] /. Degree -> Pi/180

converting d to seconds and final answer to radians

gmst[s] + eqeq0[temp0[s]]/12*Pi

TODO: need to test formula below

TODO: some of above values are interesting in and of themselves

*)

gast[s_] = (-452506800334363673497*Pi)/20593349747540136 + 
 (424749743*Pi*s)/18299087654400 - 
 (319*Pi*Sin[(Pi*(30468245256000 - 26477*s))/7776000000000]*
   Sin[(Pi*(14376164472000 + s))/38880000000000])/12000000 + 
 (Pi*Sin[(Pi*(14376164472000 + s))/38880000000000]*
   Sin[(Pi*(5881032000 + 6571*s))/51840000000])/500000

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
