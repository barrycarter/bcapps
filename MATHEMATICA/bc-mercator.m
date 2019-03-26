(*

Mercator stuff

http://mathworld.wolfram.com/MercatorProjection.html

*)

conds = {theta > 0, theta < Pi/2, lat > lat1, lat < lat2}

y[theta_] = Log[Tan[theta] + Sec[theta]]

Plot[y[theta*Degree]/Degree, {theta, 0, 85}]

FullSimplify[y'[theta], conds]

(* is Sec[theta] *)

Plot[Sec[theta], {theta, 0, Pi/2-.00001}]

f1[lat_, lat1_, lat2_] = (y[lat]-y[lat1])/(y[lat2]-y[lat1])

f2[lat_, lat1_, lat2_] = (lat-lat1)/(lat2-lat1)

distort[lat_, lat1_, lat2_] = FullSimplify[
(lat2-lat1)* (f1[lat, lat1, lat2] - f2[lat, lat1, lat2]), conds]

Plot[distort[lat, 41*Degree, 49*Degree]/Degree, {lat, 41*Degree, 49*Degree}]

Plot[distort[lat, 41*Degree, 42*Degree]/Degree, {lat, 41*Degree, 42*Degree}]

Plot[distort[lat, 81*Degree, 82*Degree]/Degree, {lat, 81*Degree, 82*Degree}]

Plot[distort[lat, 41*Degree, 43*Degree]/Degree, {lat, 41*Degree, 43*Degree}]

distort[lat, lat1, lat1+e]

Clear[maxdistort];
maxdistort[lat1_, e_] := maxdistort[lat1, e] = (NMaximize[
 {Abs[distort[lat*Degree, lat1*Degree, (lat1+e)*Degree]], 
   lat > lat1, lat < lat1+e}, lat]/Degree)[[1]]

Plot[maxdistort[lat, 1], {lat, 0, 89}]

t1442 = Table[{lat, maxdistort[lat, 1]}, {lat, 0, 89}]

t1442 = Table[maxdistort[i, 1], {i, 1, 88}]

maxdistort[85, 1]

f3[lat_, lat1_, e_] = distort[lat, lat1, lat1+e] 

Series[f3[lat, lat1, e], {e, 0, 5}]

distort[lat, lat1, lat1+1*Degree]

D[distort[lat, lat1, lat1+1*Degree], lat]

t1416 = FullSimplify[Solve[D[distort[lat, lat1, lat1+1*Degree], lat]
== 0, lat], conds]

t1418 = t1416[[1,1, 2, 1]] /. C[1] -> 0

distort[t1418, lat1, lat1+1*Degree]

plot1[lat1_] := Plot[distort[lat, lat1, lat1+1*Degree], {lat, lat1,
lat1+1*Degree}]

t1424 = Table[plot1[lat], {lat, 0, 85*Degree, 5*Degree}];






Plot[f2[lat, 60*Degree, 70*Degree] - f1[lat, 60*Degree, 70*Degree],
{lat, 60*Degree, 70*Degree}]

Maximize[f2[lat, lat1, lat2] - f1[lat, lat1, lat2], lat]





