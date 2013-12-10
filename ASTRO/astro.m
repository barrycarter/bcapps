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

Solve[Sin[ha] == c1 + c2*Cos[ha],ha]

Plot[Sin[x]+Cos[x]/10-.2,{x,0,2*Pi}]

elev2[lat_,ha_] = Simplify[
ArcSin[Sin[lat]*Sin[dec[ha]]+Cos[lat]*Cos[dec[ha]]*Cos[ha]]]

delev2[lat_,ha_] = D[elev2[lat,ha],ha]

FullSimplify[delev2[lat,ha], {-Pi/2 < lat, lat < Pi/2, ha > 0, ha < 2*Pi}]


Numerator[delev2[lat,ha]]
Solve[Numerator[delev2[lat,ha]]==0, Reals]

Solve[delev2[lat,ha]==0]
Solve[delev2[lat,ha]==0, lat]
Solve[delev2[lat,ha]==0, Reals]

elevt[lat_,t_] = Simplify[
ArcSin[Sin[lat]*Sin[dec[t]]+Cos[lat]*Cos[dec[t]]*Cos[ha[t]]]]

D[elevt[lat,t],t] /. ha'[t] -> n[t]*dec'[t]
Reduce[%==0,Reals]
Solve[%==0,Reals]
Solve[%==0, {lat,dec[t],ha[t]}]
Solve[D[elevt[lat,t],t]==0,{lat,dec[t],ha[t]}]
D[elevt[lat,t],ha[t],dec[t]]



elev[lat_,dec_,ha_] = Simplify[
ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[ha]]]

deltadec[lat_,dec_,ha_] = Simplify[D[elev[lat,dec,ha],dec]]

deltaha[lat_,dec_,ha_] = Simplify[D[elev[lat,dec,ha],ha]]

deltadiv[lat_,dec_,ha_] = Simplify[deltadec[lat,dec,ha]/deltaha[lat,dec,ha]]*
dec'[t]/ha'[t]

D[deltadiv[lat,dec,ha],t]

D[D[elev[lat,dec,ha],dec,ha]]
D[D[elev[lat,dec,ha],ha,dec]]


Solve[D[deltadiv[lat,dec,ha],ha]==0,Reals]

Solve[deltadiv[lat,dec,ha]==1, Reals]

rlat = Random[Real,{-90,90}]*Degree
rdec = Random[Real,{-28,28}]*Degree

Plot[deltadiv[rlat,rdec,ha],{ha,0,2*Pi}]

Plot[deltadec[rlat,rdec,ha],{ha,0,2*Pi}]
Plot[deltaha[rlat,rdec,ha],{ha,0,2*Pi}]
Plot[elev[rlat,rdec,ha],{ha,0,2*Pi}]

Plot[{elev[rlat,rdec,ha], elev[rlat,rdec-ha/72.,ha]},
{ha,0,2*Pi}]

Plot[{deltadec[rlat,rdec,ha],deltaha[rlat,rdec,ha]},{ha,0,2*Pi}]




ha[t_] = (366.2425/365.2425*360-360/27.321582)*Degree*t
dec[t_] = 28.58*Degree*Sin[2*Pi*(t/27.321582)]
elev[t_,lat_] = 
ArcSin[Sin[lat]*Sin[dec[t]]+Cos[lat]*Cos[dec[t]]*Cos[ha[t]]]

D[elev[t,lat],t]

(* The change in elevation at time t *)

elevdelta[t_, lat_] = D[elev[t,lat],t]

(* since denominator can't be 0... *)
Numerator[elevdelta[t,lat]] // TeXForm

(* azimuth of a fixed ra/dec object at given hour angle *)

az[ha_, dec_, lat_] = FullSimplify[
ArcTan[Cos[lat]*Sin[dec]-Sin[lat]*Cos[dec]*Cos[ha],-Sin[ha]*Cos[dec]]]

Plot[Mod[az[t,0,35*Degree],2*Pi],{t,-Pi,Pi}]

t=N[Table[Mod[az[-Pi+2*Pi/1440*i,-20*Degree,35*Degree]/Degree,360],{i,0,1440}]]

Take[t,10]





