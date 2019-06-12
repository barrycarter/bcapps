(* shortcut to computing multiple lat/lon distances from fixed pt? *)


(* assuming spherical Earth *)

(* do not use 

dist[lng1_, lat1_, lng2_, lat2_] = ArcCos[Sin[lat1]*Sin[lat2] +
Cos[lat1]*Cos[lat2]*Cos[lng1-lng2]]

*)

(* better below *)

conds = {lng1 > -Pi, lng1 < Pi, lat1 > -Pi/2, lat1 < Pi/2, 
         lng2 > -Pi, lng2 < Pi, lat2 > -Pi/2, lat2 < Pi/2};

dist[lng1_, lat1_, lng2_, lat2_] = FullSimplify[
 VectorAngle[sph2xyz[lng1, lat1, 1], sph2xyz[lng2, lat2, 1]],
conds];

Plot[dist[0, 35*Degree, x*Degree, 40*Degree], {x, -180, 180}]

FullSimplify[D[dist[lng1, lat1, lng2, lat2], lng1], conds]


FullSimplify[
 dist[lng1 + delta, lat1, lng2, lat2] - 
 dist[lng1, lat1, lng2, lat2], 
conds]

FullSimplify[
 Cos[dist[lng1 + delta, lat1, lng2, lat2]] - 
 Cos[dist[lng1, lat1, lng2, lat2]], 
conds]

FullSimplify[
 Cos[dist[lng1, lat1 + delta, lng2, lat2]] - 
 Cos[dist[lng1, lat1, lng2, lat2]], 
conds]









