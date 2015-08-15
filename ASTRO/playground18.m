(* planetary conjunctions using ecliptic coordinates, more for
explanation and general overview, not exact calculations *)

(* http://farside.ph.utexas.edu/Books/Syntaxis/Almagest/node37.html#lt4 *)

(* circular orbits, ecliptic longitude, t = days since 2000-01-01 12:00:00 *)

pos[t_,au_,j2kp_,degday_] = au*{
 Cos[(j2kp+t*degday)*Degree], Sin[(j2kp+degday)*Degree]
};

mercury[t_] = pos[t,0.38709843,252.25166724,7.00559432];
venus[t_] = pos[t,0.72332102,181.97970850,3.39777545];

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




