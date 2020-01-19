raDecLatLonGMST2azAlt[ra_, dec_, lat_, lon_, gmst_] = 
 {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat], 
  -(Cos[dec]*Sin[gmst + lon - ra])], 
 ArcTan[Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[gmst + lon - ra]^2], 
  Cos[dec]*Cos[lat]*Cos[gmst + lon - ra] + Sin[dec]*Sin[lat]]};

raDecLatLonGMST2Az[ra_, dec_, lat_, lon_, gmst_] = 
 raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[1]];

raDecLatLonGMST2Alt[ra_, dec_, lat_, lon_, gmst_] = 
 raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[2]];

raDecLatLonAlt2GMST[ra_, dec_, lat_, lon_, alt_] = {
 -lon + ra + ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]],
 -lon + ra - ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]]
};

decLatAlt2TimeAboveAlt[dec_, lat_, alt_] = 
 2*ArcCos[Sec[dec]*Sec[lat]*Sin[alt] - Tan[dec]*Tan[lat]];

decLatAlt2az[dec_, lat_, alt_] = {
 ArcCos[Sec[alt]*Sec[lat]*Sin[dec] - Tan[alt]*Tan[lat]],
 -ArcCos[Sec[alt]*Sec[lat]*Sin[dec] - Tan[alt]*Tan[lat]]};

decLatAlt2azAbs[dec_, lat_, alt_] = 
 Abs[ArcCos[Sec[alt]*Sec[lat]*Sin[dec] - Tan[alt]*Tan[lat]]];

(* raStar, decStar, raSun, decSun *)

Print[decLatAlt2TimeAboveAlt[dec, lat, 0]]

Print[decLatAlt2TimeAboveAlt[50*Degree, 0*Degree, 0]]

(* since vernal equinox *)

(* TODO: use tropical year length *)

raSun[d_] = Rationalize[2*Pi/365.2425*d, 0]

decSun[d_] = Rationalize[Sin[raSun[d]]*23.4393*Degree, 0]

riseSun[d_] = raSun[d] - decLatAlt2TimeAboveAlt[decSun[d], lat, 0]

riseSunAlt[d_, alt_, lat_] = raSun[d] - decLatAlt2TimeAboveAlt[decSun[d], lat, alt]

Print["gamma"]

Print[raSun[d] - decLatAlt2TimeAboveAlt[dec, lat, alt]/2]

(* Print[N[Simplify[riseSunAlt[d, alt, lat]]]] *)

Print["gamma"]

N[riseSun[7.]] == decLatAlt2TimeAboveAlt[decStar, lat, 0]/2

Print[FullSimplify[ArcCos[a*Tan[x]], Element[{a,x}, Reals]]]

(*

Print[raStar - decLatAlt2TimeAboveAlt[dec, lat, 0]/2]

conds = {d > 0, d < 366, raStar > -Pi, raStar < Pi, decStar > -Pi/2, decStar < Pi/2}

Print["alpha"]
(* Print[raSun[d] - decLatAlt2TimeAboveAlt[raDec[d], lat, 0]/2] *)
Print[FullSimplify[raSun[d] - decLatAlt2TimeAboveAlt[raDec[d], lat, 0]/2, conds]]
Print["alpha"]

(* Print[Simplify[raSun[d] - decLatAlt2TimeAboveAlt[raDec[d], lat, 0]/2]] *)

(* 

Print[Solve[raSun[d] - decLatAlt2TimeAboveAlt[raDec[d], lat, 0] == 
 raStar - decLatAlt2TimeAboveAlt[decStar, lat, 0]/2, d]]

*)

Print[raSun[d] - decLatAlt2TimeAboveAlt[raDec[d], lat, 0] == 
 raStar - decLatAlt2TimeAboveAlt[decStar, lat, 0]/2]

Print["beta"]

Print[Solve[a*x - ArcCos[b*Tan[c*Sin[d*x]]] == 0, x]]

Print["beta"]

Print[raSun[d] - decLatAlt2TimeAboveAlt[raDec[d], lat, 0] == 
 raStar - decLatAlt2TimeAboveAlt[decStar, lat, 0]/2]

*)

(*

disclaim: no precession, approx ra/dec (not equation of time), refraction

*)

