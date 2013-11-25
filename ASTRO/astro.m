(* Mathematica versions of some astro formulas to resolve:
 http://astronomy.stackexchange.com/questions/937/ and similar
 *)

az[ra_,dec_,lst_,lat_] =
ArcTan[-Sin[lst-ra]*Cos[dec],Cos[lat]*Sin[dec]-Sin[lat]*Cos[dec]*Cos[lst-ra]]
;

el[ra_,dec_,lst_,lat_] =
ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[lst-ra]];

Plot[el[0,0+t/2,t,60 Degree],{t,0,2*Pi}]

Plot[el[t/28.,0-t/8,t,80 Degree],{t,0,2*Pi}]

D[el[ra,dec,lst,lat],lst]


elv[t_] = el[ra[t],dec[t],t,el3]

el3[ha_,dec_,lat_,t_] =
ArcSin[Sin[lat]*Sin[dec[t]]+Cos[lat]*Cos[dec[t]]*Cos[ha[t]]];

ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[t]] /.
{lat -> 70 Degree, dec -> 13 Degree}

ArcSin[Sin[lat]*Sin[dec+2*t]+Cos[lat]*Cos[dec+2*t]*Cos[t]] /.
{lat -> 70 Degree, dec -> 13 Degree}

D[ArcSin[Sin[lat]*Sin[dec[t]]+Cos[lat]*Cos[dec[t]]*Cos[t]],t] /.
{lat -> 80 Degree, dec[t] -> 23 Degree, dec'[t]->0}

Plot[%,{t,0,2*Pi}]

moved[ha_,dec_,lat_,t_] = Simplify[Numerator[D[el3[ha,dec,lat,t],t]]]

% /. {ha'[t] -> t+1/30, dec'[t] -> 1/60}



D[%,t]

el[ra,Pi/2-lat,lst,lat]


D[el[ra,dec,lst,lat],lst] /. lst-ra -> Pi

el[dec_, lat_, ha_] = ArcSin[Sin[lat]*Sin[dec]+Cos[lat]*Cos[dec]*Cos[ha]];

el[Pi-lat,lat,ha] /. ha -> Pi

Solve[el[Pi-lat,lat,ha]==0, ha]


D[el[dec,lat,ha],ha]

D[el[dec,lat,ha],ha,ha]

