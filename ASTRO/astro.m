(* numerical orbit mercury *)

(*

init conditions at 2456658.5 = 2014-01-01 at 0000 GMT, s = sun, m = merc
in km and km/s and km/s^2

sun:
2456658.500000000 = A.D. 2014-Jan-01 00:00:00.0000 (CT)
   1.476346940316969E+05 -3.407513895873969E+05 -1.392356222336995E+04
   1.049591695983597E-02  4.032442815089396E-03 -2.431389186153114E-04

mercury:
2456658.500000000 = A.D. 2014-Jan-01 00:00:00.0000 (CT)
   1.805852832680460E+07 -6.530526643790466E+07 -6.965277303166512E+06
   3.720566883318558E+01  1.543463942254890E+01 -2.152095747620236E+00

*)

(* TODO: below sets t0 globally, which is bad *)
NDSolve[{
 t0 = 0;
 (* below is km^3 per kg per s^2 *)
 g = 6.67384*10^-20;
 (* mass of Mercury (irrelevant) + sun, in kg *)
 mm = 328.5*10^21;
 ms = 1.98855*10^30*1.0014;
 pull = g*ms;
 merc[t0] == {1.805852832680460*10^07, -6.530526643790466*10^07, 
              -6.965277303166512*10^06},
 merc'[t0] == {3.720566883318558*10^01, 1.543463942254890*10^01,
               -2.152095747620236*10^00},
 merc''[t] == -pull/Norm[merc[t]]^3*merc[t]
}, {merc}, {t, t0, t0+3650*86400}]
orbit[t_] = merc[t] /. %[[1]]

(* fx = from planet199, 26305 = start of 2014, as above (not quite)
Plot[{orbit[t*86400][[1]], f0[2456658.5+t][[1]]}, {t,0,365*4}]
Plot[{orbit[t*86400][[2]], f0[2456658.5+t][[2]]}, {t,0,365*4}]
Plot[{orbit[t*86400][[3]], f0[2456658.5+t][[3]]}, {t,0,365*4}]

distance[x1_, y1_, x2_, y2_] = Sqrt[(x1-x2)^2 + (y1-y2)^2];
f[x1_, y1_, x2_, y2_, m1_, m2_, g_] = g*m1*m2/distance[x1,y1,x2,y2]^2
a1[x1_, y1_, x2_, y2_, m1_, m2_, g_] = f[x1, y1, x2, y2, m1, m2, g]/m1
a1x[x1_, y1_, x2_, y2_, m1_, m2_, g_] =
 a1[x1, y1, x2, y2, m1, m2, g]*(x1-x2)/distance[x1,y1,x2,y2]

DSolve[{
    d[t_] = Sqrt[(x1[t]-x0[t])^2 + (y1[t]-y0[t])^2 + (z1[t]-z0[t])^2];
    d2[t_] = d[t]^3;
    D[x0[t], t,t] == (x1[t]-x0[t])/d2[t],
    D[y0[t], t,t] == (y1[t]-y0[t])/d2[t],
    D[z0[t], t,t] == (z1[t]-z0[t])/d2[t],
    D[x1[t], t,t] == -(x1[t]-x0[t])/d2[t],
    D[y1[t], t,t] == -(y1[t]-y0[t])/d2[t],
    D[z1[t], t,t] == -(z1[t]-z0[t])/d2[t]
    },
    {x0,y0,z0,x1,y1,z1},
    t
]








 

(* ellipses, more *)

(* given an ellipse with two foci in 3d *)

f1 = {x0,y0,z0};
f2 = {x1,y1,z1};

FullSimplify[Solve[Norm[{x,y,z}-f1]+Norm[{x,y,z}-f2]==c,{x,y,z}],Reals]

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

el[ha_,dec_,lat_] = FullSimplify[
ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[ha]]]

(* in degrees and hours *)

az2[ha_,dec_,lat_] = az[ha/24*2*Pi, dec*Degree, lat*Degree]/Degree
el2[ha_,dec_,lat_] = el[ha/24*2*Pi, dec*Degree, lat*Degree]/Degree

Table[{az2[ha,0,35],el2[ha,0,35]},{ha,0,24,0.5}]
Table[{az2[ha,23,35],el2[ha,0,35]},{ha,0,24,0.5}]

Table[{x[ha,23*Degree,35*Degree], y[ha,23*Degree,35*Degree]}, 
 {ha,0,2*Pi,0.1}]

Plot[{az[ha,23*Degree,35*Degree],
      az[ha,0*Degree,35*Degree],
      az[ha,-23*Degree,35*Degree]},
{ha,0,2*Pi}]


Plot[{az2[ha,23,35],
      az2[ha,0,35],
      az2[ha,-23,35]
}, {ha,0,24}]

Plot[{el2[ha,23,35],
      el2[ha,0,35],
      el2[ha,-23,35]
}, {ha,0,24}]

(* gnomon position *)

x[ha_,dec_,lat_] = FullSimplify[Cot[el[ha,dec,lat]]*Cos[az[ha,dec,lat]+Pi]]
y[ha_,dec_,lat_] = FullSimplify[Cot[el[ha,dec,lat]]*Sin[az[ha,dec,lat]+Pi]]

ParametricPlot[{x[ha,23 Degree,35 Degree], y[ha, 23 Degree, 35 Degree]},
 {ha,0,Pi/4}, PlotRange -> {{-5,5},{-5,5}}]

ParametricPlot[{x[ha,23 Degree,35 Degree], y[ha, 23 Degree, 35 Degree]},
 {ha,-Pi/2,Pi/2}]

ParametricPlot[{x[ha,-23 Degree,35 Degree], y[ha, -23 Degree, 35 Degree]},
 {ha,-Pi/4,Pi/4}]







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

(* a and b are not the minor/major axes, but... *)

area[a_,b_] = Pi*(a+2b)/2*Sqrt[b]*Sqrt[a+b]

Plot[y[x,2,1],{x,-3,1}, AspectRatio -> Automatic]

xtri[theta_,a_,b_] =
(x /. FullSimplify[Solve[y[x,a,b]==x*Tan[theta],x]][[1]])*If[theta>Pi/2,-1,1]



(* area "swept out" given value of x *)

(* this has no closed form *)

area[x_,a_,b_] := x*y[x,a,b]/2 + NIntegrate[y[t,a,b],{t,x,b}]

Plot[area[x,2,1],{x,-3,1}]

x[area2_,a_,b_] := x/. FindRoot[area[x,a,b] == area2, {x,0,b}]

Plot[x[a,2,1],{a,0,1}]

Plot[x[a,2,1],{a,0,2}]

Plot[x[a,2,1]/Cos[Pi*a/area[2,1]],{a,0,area[2,1]/2}]
Plot[x[a,2,1],{a,0,area[2,1]/2}]










(* nontriangular portion at angle theta *)

Integrate[y[x,a,b],{x,xtri[theta,a,b],b}]

(* triangular area *)

xtri[theta,a,b]*y[xtri[theta,a,b],a,b]/2

(* total area for specific ellipse *)

ta[theta_,a_,b_] := NIntegrate[y[x,a,b],{x,xtri[theta,a,b],b}] +
xtri[theta,a,b]*y[xtri[theta,a,b],a,b]/2 

Plot[ta[theta,2,1],{theta,0,Pi/2}]
Plot[theta*2*1/2,{theta,0,Pi/2}]

(* difference between "average" area and true area *)

Plot[ta[theta,2,1]-theta*2*1/2,{theta,0,Pi/2}]

(* difference between true area + double triangle approx *)

xtri[theta,a,b]*y[xtri[theta,a,b],a,b]/2 + 
(b-xtri[theta,a,b])*y[xtri[theta,a,b],a,b]/2 

b*y[xtri[theta,a,b],a,b]/2

b*y[xtri[theta,a,b],a,b]/2 /. {b->1, a->2}

Plot[%,{theta,0,Pi/2}]

Plot[ta[theta,2,1] - b*y[xtri[theta,a,b],a,b]/2 /. {b->1, a->2}, 
{theta,0,Pi/2}]
