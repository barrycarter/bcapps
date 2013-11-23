(* Mathematica versions of some astro formulas to resolve:
 http://astronomy.stackexchange.com/questions/937/ and similar
 *)

az[ra_,dec_,lst_,lat_] =
ArcTan[-Sin[lst-ra]*Cos[dec],Cos[lat]*Sin[dec]-Sin[lat]*Cos[dec]*Cos[lst-ra]]
;

el[ra_,dec_,lst_,lat_] =
ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[lst-ra]];

elv[t_] = el[ra[t],dec[t],t,lat]

D[%,t]

el[ra,Pi/2-lat,lst,lat]


D[el[ra,dec,lst,lat],lst] /. lst-ra -> Pi

el[dec_, lat_, ha_] = ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[ha]];

el[Pi-lat,lat,ha] /. ha -> Pi

Solve[el[Pi-lat,lat,ha]==0, ha]


D[el[dec,lat,ha],ha]

D[el[dec,lat,ha],ha,ha]

