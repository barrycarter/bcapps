(* Mathematica versions of some astro formulas to resolve:
 http://astronomy.stackexchange.com/questions/937/ and similar
 *)

(* elevation of object given hour angle, declination, latitude *)

elev[ha_,dec_,lat_] = 
ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[ha]];

elev[c1+(27/28)*t, Cos[t+c2]/60, lat]


elevdha[ha_,dec_,lat_] = D[elev[ha,dec,lat],ha]
elevddec[ha_,dec_,lat_] = D[elev[ha,dec,lat],dec]

D[elev[c+(30/31)*t, dec,lat],t]

D[elev[c+(30/31)*t, dec,lat],t] /. lat -> 60 Degree


Solve[D[elev[c+(30/31)*t, dec,lat],t]==1/60]

Solve[elevdha[ha,dec,lat]==elevddec[ha,dec,lat]]

Sin[ha] -> Cos[ha] Tan[dec] - Tan[lat]

Solve[Sin[ha]==Cos[ha] Tan[dec] - Tan[lat]]

(* at ha==0, the above is just dec==+-lat *)

Solve[Sin[1] == Cos[1]*Tan[dec] - Tan[50. Degree]]

(* a 75 degree object at 50 lat *)

Plot[elev[t,75 Degree,50 Degree],{t,0,2*Pi}]
Plot[elevdha[ha,75 Degree,50 Degree], {ha,0,2*Pi}]

Plot[elev[t*(30/31),0,60 Degree],{t,0,2*Pi}]

