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
ArcTan[Cos[lat]*Sin[dec]-Sin[lat]*Cos[dec]*Cos[ha],-Sin[ha]*Cos[dec]]
, Reals]

Plot[az[t,20*Degree,35*Degree],{t,0,2*Pi}]

daz[ha_,dec_,lat_] = FullSimplify[D[az[ha,dec,lat],ha],Reals]

ddaz[ha_,dec_,lat_] = FullSimplify[D[az[ha,dec,lat],ha,ha],Reals]

Plot[daz[t,20*Degree,35*Degree],{t,0,2*Pi}]

FullSimplify[daz[Pi/2,dec,lat], Reals]
FullSimplify[daz[Pi,dec,lat], Reals]
FullSimplify[daz[3*Pi/2,dec,lat], Reals]

N[daz[Pi/2,-20*Degree,35*Degree]]

Plot[{az[t,23*Degree,55*Degree],
      az[t,23*Degree,45*Degree],
      az[t,23*Degree,35*Degree],
      az[t,23*Degree,25*Degree],
      t-Pi},
{t,0,2*Pi}]

Plot[{az[t,-23*Degree,55*Degree],
      az[t,-23*Degree,45*Degree],
      az[t,-23*Degree,35*Degree],
      az[t,-23*Degree,25*Degree],
      t-Pi},
{t,0,2*Pi}]

Plot[{az[t,-0*Degree,55*Degree],
      az[t,-0*Degree,45*Degree],
      az[t,-0*Degree,35*Degree],
      az[t,-0*Degree,25*Degree],
      t-Pi},
{t,0,2*Pi}]

(* ellipses *)

(* instantaneous radius from center (not focus) of ellipse *)

r[a_,b_,th_] = FullSimplify[a*b/Sqrt[(b*Cos[th])^2+(a*Sin[th])^2],Reals]
dr[a_,b_,th_] = FullSimplify[D[r[a,b,th],th],Reals]
area[a_,b_,th_] = FullSimplify[Integrate[r[a,b,th]*dr[a,b,th],th],Reals]

Plot[area[2,1,th],{th,0,Pi/2}]

(* difference between area of ellipse from center + from focus *)

tri[a_,b_,th_] = FullSimplify[r[a,b,th]*Sin[th]*Sqrt[a^2-b^2]/2,Reals]

(* area from focus *)

focarea[a_,b_,th_] = FullSimplify[area[a,b,th]-tri[a,b,th],Reals]

Plot[focarea[2,1,th],{th,0,2*Pi}]

(* position when angle is theta *)

posx[a_,b_,th_] = r[a,b,th]*Cos[th]
posy[a_,b_,th_] = r[a,b,th]*Sin[th]

ParametricPlot[{posx[2,1,t],posy[2,1,t]},{t,0,2*Pi}]
ParametricPlot[{posx[2,1,t],posy[2,1,t]},{t,0,Pi}]

(* if f0 and f1 are foci, distance is constant *)

Solve[a+f0 + a-f0 == Sqrt[f0^2+b^2] + Sqrt[f0^2+b^2], {f0,f1}]

(* the foci are thus +-Sqrt[a^2-b^2] *)

(* distance from right focus *)

drf[a_,b_,th_] = Norm[{posx[a,b,th]-Sqrt[a^2+b^2], posy[a,b,th]}]

Integrate[drf[a,b,th],th]

(* different ellipses, foci at (0,0) and (-a,0), sum distance a+2b *)

y[x_,a_,b_] = 
y /. FullSimplify[Solve[Sqrt[x^2+y^2] + Sqrt[(x+a)^2+y^2] == a+2b, y]][[2]]

y[x,2,1]

Plot[y[x,2,1],{x,-3,1}, AspectRatio -> 3/8]

xtri[theta_,a_,b_] = x /. FullSimplify[Solve[y[x,a,b]==x*Tan[theta],x]][[1]]

Plot[x*Sin[40*Degree],{x,0,2}]




