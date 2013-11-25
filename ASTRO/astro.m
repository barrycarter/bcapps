(* Mathematica versions of some astro formulas to resolve:
 http://astronomy.stackexchange.com/questions/937/ and similar
 *)

(*

To determine ha[t] and dec[t], I choose t=0 when the moon's
declination and hour angle are both 0 [such a time must exist]

Local sidereal time increases by 366.2425/365.2425*360 degrees per
calendar day.

The moon's RA increases 360 degrees every lunar sidereal month or
360/27.321582 degrees per day.

The moon's hour angle thus increases
366.2425/365.2425*360-360/27.321582 (LST-RA) per day

The moon's declination is a sinusoidal wave whose average declination
is 0, and whose period is the moon's sidereal period (27.321582 days);
the moon's maximal inclination is 28.58 degrees. This gives us the
sinusoidal equation below.

t is measured in calendar days; using the standard formula for
elevation at latitude

*)

ha[t_] = (366.2425/365.2425*360-360/27.321582)*Degree*t
dec[t_] = 28.58*Sin[2*Pi*(t/27.321582)]
elev[t_,lat_] = 
ArcSin[Sin[lat]*Sin[dec[t]]+Cos[lat]*Cos[dec[t]]*Cos[ha[t]]]

(* The change in elevation at time t *)

elevdelta[t_, lat_] = D[elev[t,lat],t]

(* this confirms nonunimodality *)

Plot[elev[t, 60 Degree]/Degree, {t,5,6}]
Plot[elev[t, 10 Degree]/Degree, {t,5,6}]
Plot[elev[t, 30 Degree]/Degree, {t,5,6}]
Plot[elev[t, 80 Degree]/Degree, {t,5,6}]

(*

Finding a real life example:





*)
