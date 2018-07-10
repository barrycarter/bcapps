(*

https://astronomy.stackexchange.com/questions/26347/given-sunrise-noon-sunset-longitude-and-latitude-can-i-calculate-the-hight

math2 ~/BCGIT/ASTRO/bc-astro-formulas.m

TODO: not dinging Holtz

known: sunrise/set + noon, latitude and longitude

simptan simplifies tangent

*)

raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst]

simpAlt[ra_, dec_, lat_, lon_, gmst_] = 
 ArcTan[(Cos[dec]*Cos[lat]*Cos[gmst + lon - ra] + Sin[dec]*Sin[lat])/
  Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[gmst + lon - ra]^2]]

simpAltH[h_, dec_, lat_] = 
ArcTan[(Cos[dec]*Cos[h]*Cos[lat] + Sin[dec]*Sin[lat])/
  Sqrt[Cos[dec]^2*Sin[h]^2 + (Cos[lat]*Sin[dec] - Cos[dec]*Cos[h]*Sin[lat])^2]]

simpAltH[h, lat-delta, lat]

simpAltH[h,dec,lat]

s1321 = FullSimplify[Solve[
 Tan[simpAltH[h,dec,lat]] == Tan[-50/60*Degree], dec],conds]

In[6]:= FullSimplify[Solve[decLatAlt2TimeAboveAlt[dec, lat,
-50/60*Degree] == x, dec],conds]

s1332 = Solve[decLatAlt2TimeAboveAlt[dec, lat, -50/60*Degree] == x, dec]

dec to roughly -ArcTan[Cos[x/2]*Cot[lat]]

raDecLatLonGMST2Alt[ra, -ArcTan[Cos[x/2]*Cot[lat]], lat, lon, gmst]



TODO: remember to convert h from radians to hours

Series[simpAltH[h,dec,lat],{h,0,2}]

Solve[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst] == -50/60*Degree, dec]

FullSimplify[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst] /. simptan, conds]

given sunrise (-50/60*Degree)/set

FullSimplify[Tan[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst]], conds]

s1396 =
Solve[FullSimplify[Tan[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst]], conds]
  == Tan[-50/60*Degree], dec]



