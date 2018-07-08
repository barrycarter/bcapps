(*

https://astronomy.stackexchange.com/questions/26875/how-to-calculate-the-time-for-the-solar-disk-to-pass-the-horizon-and-transits-l

math ~/BCGIT/ASTRO/bc-astro-formulas.m


*)

raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst]

HADecLat2azEl[ha,dec,lat]

raDecLatLonGMST2Az[ra, dec, lat, lon, gmst]

raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst]

Solve[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst] == Pi, gmst]

D[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst], gmst]

Simplify[raDecLatLonGMST2Az[ra, dec, lat, lon, ra-lon], Reals]         

D[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst], gmst] /. gmst -> ra-lon

Simplify[
D[raDecLatLonGMST2Az[ra, dec, lat, lon, gmst], gmst] /. gmst -> ra-lon
]

above is: -(Cos[dec] Csc[dec - lat])



Simplify[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst] /. gmst -> ra-lon,conds]

ArcTan[Abs[Sin[dec - lat]], Cos[dec - lat]]

Simplify[
Cos[raDecLatLonGMST2Alt[ra, dec, lat, lon, gmst]] /. gmst -> ra-lon,
conds]

azChangeAtNoon[dec_, lat_] = -(Cos[dec] Csc[dec - lat])

FullSimplify[
azChangeAtNoon[dec, lat]*Cos[ArcTan[Abs[Sin[dec - lat]], Cos[dec - lat]]],
conds]

so it really is Cos[dec] radians per radian hour

2.13333 minutes at the equator

128 seconds

3h49m11s = radian hour







above is essentially lat-dec



