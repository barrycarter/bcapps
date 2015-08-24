(* planetary conjunctions using ecliptic coordinates, more for
explanation and general overview, not exact calculations *)

(* what if jupiters orbit were exactly 12 years? *)

fakeearth[t_] = {Cos[2*Pi*t],Sin[2*Pi*t]};

(* below from Keplers R^3/T^2 = constant *)

fakeplan[t_,p_] = p^(2/3)*{Cos[2*Pi*t/p],Sin[2*Pi*t/p]};

fakeplan2[t_,p_] = p^(2/3)*{Cos[2*Pi*(t/p-t)],Sin[2*Pi*(t/p-t)]};

fakeplan3[t_,p_] = fakeplan2[t,p]-{1,0};

(* this is the slope of the vector from earth, sun fixed *)

fakeplan4[t_,p_] = Apply[Divide,fakeplan3[t,p]];

Chop[Series[Apply[ArcTan,fakeplan3[t,12.]],{t,0,15}]];

Chop[Series[Apply[ArcTan,fakeplan3[t,5.20248019^(3/2)]],
{t,11.8663/10.8663/2,15}]];

(* above repeats every 12/11 year or whatever *)

(* letting u = t/p we have ... *)

Series[Apply[ArcTan,fakeplan3[p*u,t/u]],{t,0,5}];
Series[Apply[ArcTan,fakeplan3[2*u,t/u]],{t,0,5}];


Plot[{Apply[Divide,fakeplan2[t,1.5]-{1,0}],Apply[Divide,fakeplan2[t,12]-{1,0}]},{t,0,.5},AxesOrigin->{0,0}];

ParametricPlot[{fakeearth[t],fakeplan[t,2]},{t,0,1},AxesOrigin->{0,0}];

Plot[Apply[ArcTan,fakeplan[t,11.866308987591655]-fakeearth[t]]/Degree,{t,0,150}]

fakejupiter[t_] = 144^(1/3)*{Cos[Pi*t/6],Sin[Pi*t/6]};

(* 13 years *)

fakejupiter2[t_] = 169^(1/3)*{Cos[Pi*t/6.5],Sin[Pi*t/6.5]};

ParametricPlot[{fakeearth[t],fakejupiter[t]},{t,0,1}];

Plot[Apply[ArcTan,fakejupiter2[t]-fakeearth[t]]/Degree,{t,0,13}]





(* http://ssd.jpl.nasa.gov/txt/p_elem_t2.txt *)

(* circular orbits, ecliptic longitude, t = days since 2000-01-01 12:00:00 *)

pos[t_,au_,j2kp_,degday_] = au*{
 Cos[(j2kp+t*degday/36525)*Degree], Sin[(j2kp+t*degday/36525)*Degree]
};

mercury[t_] = pos[t,0.38709843,252.25166724,149472.67486623];
venus[t_] = pos[t,0.72332102,181.97970850,58517.81560260];
(* cheating and using EMB, but that's close + I'm only seeking approx *)
earth[t_] = pos[t,1.00000018,100.46691572,35999.37306329];
mars[t_] = pos[t,1.52371243,-4.56813164,19140.29934243];
jupiter[t_] = pos[t,5.20248019,34.33479152,3034.90371757];
saturn[t_] = pos[t,9.54149883,50.07571329,1222.11494724];
uranus[t_] = pos[t,19.18797948,314.20276625,428.49512595];

Plot[Apply[ArcTan,jupiter[t]-earth[t]]/Degree/15,{t,0,365}]

Plot[{Apply[ArcTan,jupiter[t]-earth[t]],
      Apply[ArcTan,venus[t]-earth[t]]},
{t,0,3650}]

Plot[{Apply[ArcTan,jupiter[t]-earth[t]]-
      Apply[ArcTan,venus[t]-earth[t]]},
{t,0,3650}]

conds = Element[{t,a1,a2,a3,b1,b2,b3},Reals]
o[t_] = {Cos[t],Sin[t]}
o1[t_] = a1*{Cos[a2*t+a3],Sin[a2*t+a3]}
o2[t_] = b1*{Cos[b2*t+b3],Sin[b2*t+b3]}
Simplify[VectorAngle[o1[t]-o[t],o2[t]-o[t]],conds]

(* equating slopes *)

Solve[
(o1[t]-o[t])[[1]]/(o1[t]-o[t])[[2]] == (o2[t]-o[t])[[1]]/(o2[t]-o[t])[[2]],
t]


Solve[(o1[t]-o[t]).(o2[t]-o[t]) == a1*b1,t,Reals]
Solve[(o1[t]-o[t]).(o2[t]-o[t]) == 0,t,Reals]

Plot[First[venus[t]-earth[t]]*Last[jupiter[t]-earth[t]] -
     Last[venus[t]-earth[t]]*First[jupiter[t]-earth[t]],
{t,0,2000}]

FindAllCrossings[First[venus[t]-earth[t]]*Last[jupiter[t]-earth[t]] -
     Last[venus[t]-earth[t]]*First[jupiter[t]-earth[t]],
{t,0,365000}]

(* matrix to convert equatorial to ecliptic coordinates J2000 only(?) *)

equ2ecl[e_] = {{1,0,0},{0,Cos[e],Sin[e]},{0,-Sin[e],Cos[e]}};

(* approx obliquity)

obq = Pi*5063835528000/38880000000000;

equ2ecl = equ2ecl[obq];

(* at 2451545.0 2000-01-01 12:00:00 *)

j2000 = 2451545.;

Apply[ArcTan,Take[equ2ecl.posxyz[j2000,jupiter],2]]/Degree
Apply[ArcTan,Take[equ2ecl.posxyz[j2000,venus],2]]/Degree
Apply[ArcTan,Take[equ2ecl.posxyz[j2000,earth],2]]/Degree



(* conjunction of 2003, venus/jupiter: 2452872.923665149 *)

jday = 2452872.923665149;

Apply[ArcTan,Take[equ2ecl.posxyz[jday,jupiter],2]]/Degree
Apply[ArcTan,Take[equ2ecl.posxyz[jday,venus],2]]/Degree
Apply[ArcTan,Take[equ2ecl.posxyz[jday,earth],2]]/Degree

psize=.05;

Graphics[{
 RGBColor[1,1,0],
 Circle[{0,0},psize],
 RGBColor[0,0,1],
 Circle[{0,0},1],
 Circle[{Cos[-32.1785*Degree],Sin[-32.1785*Degree]},psize],
 RGBColor[0,1,0],
 Circle[{0,0},0.723332],
 Point[{0.723332*Cos[149.837*Degree],0.723332*Sin[149.837*Degree]}],
 Circle[{0,0},5.204267],
 Point[{5.204267*Cos[148.817*Degree],5.204267*Sin[148.817*Degree]}],
 Line[{{Cos[-32.1785*Degree],Sin[-32.1785*Degree]},
      {5.204267*Cos[148.817*Degree],5.204267*Sin[148.817*Degree]}}]
}]



Plot[earthangle[t,venus,jupiter],{t,2452640,2452640+700}]

f[t_] := earthangle[t,venus,jupiter];

ternary[2452870.,2452875.,f,10^-6]



ternary[a_,b_,f_,eps_] := Module[{t},
 If[Abs[a-b]<eps,Return[{(a+b)/2,f[(a+b)/2]}]];
 t = Table[{x,f[x]},{x,a,b,(b-a)/3}];
Print["DEBUG:",t]'
 If[t[[2,2]]<=t[[3,2]]<=t[[4,2]],Return[ternary[a,t[[3,1]],f,eps]]];
 If[t[[3,2]]<=t[[2,2]]<=t[[1,2]],Return[ternary[t[[2,1]],b,f,eps]]];
 If[t[[2,2]]<t[[1,2]] && t[[3,2]]<t[[4,2]],
  Return[ternary[t[[2,1]],t[[3,1]],f,eps]]];
 Return[{Null,Null}];
]

