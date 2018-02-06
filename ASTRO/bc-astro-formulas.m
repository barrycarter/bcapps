(*

<docs>

Caveats: we assume fixed ra, dec, lat, lon

Measurement units: km, radians

Time units used:

  - mjd: modified Julian date [number of days since 2000 January 1, at 12h UT]
  - gmst: Greenwich mean sidereal time (radians)
  - time: sidereal time (radians) [2*pi ~ 23h56m clock time]

Angular units used:

  - rad: radians
  - deg: degrees
  - hour: hours (1h = 15 degrees = pi/12 radians)

Ellipse properties:

  - smajor: length of semimajor axis (km)
  - sminor: length semiminor axis (km)
  - ecc: eccentricity (unitless)

Orbit properties (elliptical, assumes fixed ecliptic):

  - incl: inclination to the ecliptic (radians)
  - peri: periapsis distance (km)
  - apo: apoapsis distance (km)
  - periarg: argument of the periapsis (radians)
  - ascnode: longitude of the ascending node (radians)
  - meananom: mean anomaly (radians) 
  - trueanom: true anomaly (radians)

TODO: https://en.wikipedia.org/wiki/File:Orbit1.svg

TODO: move todos to one place

TODO: this solves the following questions (some solved) (doublecheck some):

https://astronomy.stackexchange.com/questions/240/how-does-moonrise-moonset-azimuth-vary-with-time

https://astronomy.stackexchange.com/questions/24598/how-to-calculate-the-maximum-and-minimum-solar-azimuth-at-a-given-location [TODO: azimuth at rise/set equation here may be better than mine]

https://earthscience.stackexchange.com/questions/13032/how-much-of-one-day-can-be-considered-nighttime-on-average

https://astronomy.stackexchange.com/questions/24304/expression-for-length-of-sunrise-sunset-as-function-of-latitude-and-day-of-year

https://astronomy.stackexchange.com/questions/24195/finding-hour-angle-altitude

https://astronomy.stackexchange.com/questions/24121/is-the-shortest-day-duration-constant

https://astronomy.stackexchange.com/questions/24119/computing-the-average-hours-of-sunshine-at-given-locationorientation

https://astronomy.stackexchange.com/questions/24094/what-should-be-the-declination-of-a-star-to-be-marginally-circumpolar-given-the

https://astronomy.stackexchange.com/questions/24632/how-do-i-adjust-the-sunrise-equation-to-account-for-elevation

https://astronomy.stackexchange.com/questions/24431/will-time-that-moon-crosses-meridian-always-be-periodic (maybe)

https://astronomy.stackexchange.com/questions/14492/need-simple-equation-for-rise-transit-and-set-time (re-answers this)

Celestial position:

  - ra: right ascension (radians)
  - dec: declination (radians)
  - ha: hour angle (radians) [sidereal hours since culmination]
  - az: azimuth (radians) [0 = north, pi/2 = east]
  - alt: altitude (radians) [not to be confused with geographic altitude]

Geographic position:

  - lat: latitude (radians)
  - lon: longitude (radians)
  - rad: distance from center of Earth (km)
  - el: elevation (km) above the reference ellipsoid (Earth)

Other numbers:

  - ecl: inclination of the ecliptic to the equator (radians)

Modifier:

  - rise: object rises
  - set: object sets
  - culm: object culminates (highest altitude)
  - up: object is above horizon
  - above: object's altitude is above given parameter
  - below: object's altitude is below given parameter
  - distang: angular distance
  - distlen: length distance
  - cons: this value when treated as a constant
  
</docs>

<formulas>

raDecLatLonGMST2azAlt[ra_, dec_, lat_, lon_, gmst_] = 
 {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat], 
  -(Cos[dec]*Sin[gmst + lon - ra])], 
 ArcTan[Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[gmst + lon - ra]^2], 
  Cos[dec]*Cos[lat]*Cos[gmst + lon - ra] + Sin[dec]*Sin[lat]]}

raDecLatLonAlt2GMST[ra_, dec_, lat_, lon_, alt_] = {
 -lon + ra + ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]],
 -lon + ra - ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]]
};

decLatAlt2TimeAboveAlt[dec_, lat_, alt_] = 
 2*ArcCos[Sec[dec]*Sec[lat]*Sin[alt] - Tan[dec]*Tan[lat]]

(* the strict less thans here allow better simplification *)

conds = {-Pi < {ra, lon, gmst, az} < Pi, -Pi/2 < {dec, lat, alt} < Pi/2}

(* simplifications that dont always apply but can be useful *)

simptan = {ArcTan[x_,y_] -> ArcTan[y/x]}

conds2 = {0 <= {ra, lon, gmst, az, dec, lat, alt} <= Pi/2}

</formulas>

<sources>


</sources>

<work>

raDecLatLonGMST2azAlt[ra, dec, lat, lon,
 raDecLatLonAlt2GMST[ra,dec,lat,lon,0][[1]]][[1]]

TODO: use Cos vs two arg ArcTan almost works sometimes

FullSimplify[raDecLatLonGMST2azAlt[ra, dec, lat, lon,
 raDecLatLonAlt2GMST[ra,dec,lat,lon,alt][[1]]][[1]], conds]

FullSimplify[raDecLatLonGMST2azAlt[ra, dec, lat, lon,
 raDecLatLonAlt2GMST[ra,dec,lat,lon,alt][[2]]][[1]], conds]





FullSimplify[Cos[raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst][[1]]],conds]

above is not nice

FullSimplify[ArcCos[Cos[raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst][[1]]]],
 conds]



FullSimplify[Cos[raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst][[2]]],conds]

also not that great

for arccos, it's +- the value given




raDec2azAltMat[lat_, lon_, gmst_] = 
{{-(Cos[gmst + lon]*Sin[lat]), -(Sin[lat]*Sin[gmst + lon]), Cos[lat]}, 
 {-Sin[gmst + lon], Cos[gmst + lon], 0}, {Cos[lat]*Cos[gmst + lon], 
  Cos[lat]*Sin[gmst + lon], Sin[lat]}}

azAlt2raDecMat[lat_, lon_, gmst_] = 
 FullSimplify[Inverse[raDec2azAltmat[lat,lon,gmst]], conds]

raDec2azAltMat[lat,lon,gmst].sph2xyz[{ra,dec,1}] ==
 {Cos[az] Cos[el], Cos[el] Sin[az], Sin[el]}

tempGMST2az[gmst_] = raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst][[1]]



Solve[(mat[lat,lon,gmst].sph2xyz[{ra,dec,1}])[[3]]==0, gmst, Reals]



xim = FullSimplify[sph2xyz[Flatten[{Apply[raDecLatLonGMST2azAlt, 
 Flatten[{Take[xyz2sph[{1,0,0}],2], lat, lon, gmst}]],
1}]],conds]

yim = FullSimplify[sph2xyz[Flatten[{Apply[raDecLatLonGMST2azAlt, 
 Flatten[{Take[xyz2sph[{0,1,0}],2], lat, lon, gmst}]],
1}]],conds]

zim = FullSimplify[sph2xyz[Flatten[{Apply[raDecLatLonGMST2azAlt, 
 Flatten[{0, Pi/2, lat, lon, gmst}]],
1}]],conds]

mat = Transpose[{xim,yim,zim}];

s1833 = Take[FullSimplify[xyz2sph[mat.sph2xyz[{ra,dec,1}]], conds],2]

s1834 = raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst]

s1833-s1834 is {0,0} as desired!












using raDecLatLonGMST2azAlt

ra/dec 

{0,0} = {1,0,0} -> 

s1228 = raDecLatLonGMST2azAlt[0,0,lat,lon,gmst]

FullSimplify[sph2xyz[s1228[[1]], s1228[[2]], 1], conds]

xim = FullSimplify[sph2xyz[s1228[[1]], s1228[[2]], 1], conds]

s1230 = raDecLatLonGMST2azAlt[0,90*Degree,lat,lon,gmst]

zim = FullSimplify[sph2xyz[s1230[[1]], s1230[[2]], 1], conds]

s1232 = raDecLatLonGMST2azAlt[Pi/2,0,lat,lon,gmst]

yim = FullSimplify[sph2xyz[s1232[[1]], s1232[[2]], 1], conds]

mat = 
{{-(Cos[gmst + lon]*Sin[lat]), -Sin[gmst + lon], Cos[lat]*Cos[gmst + lon]}, 
 {-(Sin[lat]*Sin[gmst + lon]), Cos[gmst + lon], Cos[lat]*Sin[gmst + lon]}, 
 {Cos[lat], 0, Sin[lat]}};

s1235 = FullSimplify[xyz2sph[mat.sph2xyz[{ra,dec,1}]],conds]

s1236 = raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst]

Take[s1235,2] - s1236

res1749 = FullSimplify[Take[xyz2sph[mat.sph2xyz[{ra,dec,1}]],2],conds]
res1750 = raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst]







trying matrix approach

north pole first

{ra, dec} -> {az, el}

{0, 90} = {0,0,1} -> {0, lat} -> {Cos[lat], 0, Sin[lat]}

{0, 0} = {1,0,0} -> 

{gmst+lon, 0} = {Cos[gmst + lon], Sin[gmst + lon], 0} -> 


{0, 90} -> {0, lat}

{gmst+lon, 0} -> {180, 90-lat}

{0,0,1} -> {Cos[lat], 0, Sin[lat]}

{Cos[gmst + lon], Sin[gmst + lon], 0} -> {-Sin[lat], 0, Cos[lat]}

again using HA sigh






(* conds={0 <= gmst <= 2*Pi, 0 <= ra <= 2*Pi, -Pi <= dec <= Pi, -Pi <=
lat <= Pi, -Pi/2 <= alt <= Pi/2, }; *)

FullSimplify[HADecLat2azAlt[gmst+lon-ra, dec, lat],conds]

raDecLatLonGMST2azAlt[ra_, dec_, lat_, lon_, gmst_] = 
 {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat], 
  -(Cos[dec]*Sin[gmst + lon - ra])], 
 ArcTan[Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[gmst + lon - ra]^2], 
  Cos[dec]*Cos[lat]*Cos[gmst + lon - ra] + Sin[dec]*Sin[lat]]}

Solve[raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst][[2,2]]==0, gmst]

raDecLatLon2GMSTRise[ra_, dec_, lat_, lon_] = 
 -lon + ra - ArcCos[-(Tan[dec] Tan[lat])]

raDecLatLon2GMSTSet[ra_, dec_, lat_, lon_] = 
 -lon + ra + ArcCos[-(Tan[dec] Tan[lat])]

raLon2GMSTCulm[ra_, lon_] = -lon + ra

decLat2TimeUp[dec_, lat_] = 2*ArcCos[-(Tan[dec] Tan[lat])]

raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst][[2]]

s1542 = 
 Solve[(raDecLatLonGMST2azAlt[ra,dec,lat,lon,gmst][[2]] /. simptan) == alt, 
 gmst]

FullSimplify[(gmst /. s1542[[1]]) + lon - ra, conds]

s1559 = (gmst /. s1542[[1]]) + lon - ra

FullSimplify[s1559[[2,1]],conds]

s1603 = FullSimplify[s1559[[2,1]],conds] /. Sign[Cos[dec]*Cos[lat]] -> 1

s1605= Expand[s1603 /. Sqrt[Sec[alt]^2*Tan[alt]^2] -> Sec[alt]*Tan[alt]]

s1609 = s1605+Tan[dec]*Tan[lat]

(* TODO: test below due to sign [not sine] weirdness *)

decLatAlt2TimeAbove[dec_, lat_, alt_] = 
 2*ArcCos[Sin[alt]/Cos[dec]/Cos[lat] - Tan[dec]*Tan[lat]]

decLatAlt2TimeAbove[dec_, lat_, alt_] = 
 2*ArcCos[Sin[alt]/Cos[dec]/Cos[lat] - Tan[dec]*Tan[lat]]

NOTE: decLatAlt2TimeAboveAlt is geometric rise/set for alt = 0



-23*Degree, 35*Degree, 0.]/Pi*12

decLatAlt2TimeAbove[-23*Degree, 35*Degree, -6.*Degree]/Pi*12





















lstRaDecLatLon2azAlt[lst, lst, dec, lat, lon]

ignore corner cases

two arg form or arctan, not error checked for simplification, not mod 2*Pi for simplication


(* derive formulas here, place in formulas section *)

</work>

TODO: include my other greek weirdness thing and reference it

TODO: 5 of 7 gives other 2 (but do I care) [would give 21 formulas, eg]

TODO: disclaim everything incl incomplete + not 100% accurate,
community wiki, encourage others to add but contact me; use your libs when possible, this is more for meta

TODO: ellipse stuff, r^3/t^2, Niawem -> orbit position

TODO: note translation to languages is not necessary just conv

NOTE: formulas are interesting because closed form, unlike libs-- but use libs when possible

TODO: source formulas individually?

Hopefully canonical-at-last astronomical formulas, simple ones
building up. Coventions:

all units are in radians except where noted

functions are camel cased on each side with "2" representing "to"

Modules only permitted with "="

TODO: distinguish altitude/elevation once and for all

TODO: rationalization is used to preserve accuracy (but does not imply
infinite accuracy)

TODO: rosetta-fy

TODO: see bc-astro.dot for adjacency graph (build this up)

ha - hour angle (radians)

haSet - local hour angle setting time

haRise - local hour angle rising time

xyzAltAz - the xyz coordinates for a given altitude and azimuth
(virtual sphere of radius 1)

xyzRaDec - the xyz coordinates for a given right ascension and
declination (virtual sphere of radius 1)

xyzEarth - xyz coordinates on Earth for current epoch, in km (no
precession/nutation)

*)

(* these conditions apply to the values above *)

conds = {-Pi/2<dec<Pi/2, -Pi/2<lat<Pi/2, 0<ra<2*Pi, -Pi<lon<Pi,
Element[date,Reals], Element[gmst,Reals]
}

(* constants (km) *)

earthMeanRadius = 6378.1370;
earthPolarRadius = 6356.7523;

(* http://en.wikipedia.org/wiki/Earth_radius#Geocentric_radius *)

lat2earthRadius[lat_] = Sqrt[
((earthMeanRadius^2*Cos[lat])^2 + (earthPolarRadius^2*Sin[lat])^2)/
((earthMeanRadius*Cos[lat])^2 + (earthPolarRadius*Sin[lat])^2)
]

(* http://aa.usno.navy.mil/faq/docs/GAST.php converted to radians *)

date2gmst[date_] = (18.697374558+24.06570982441908*date)/12*Pi

gmstLon2lst[gmst_,lon_] = gmst+lon

lstRa2ha[lst_,ra_] = lst-ra

(* http://idlastro.gsfc.nasa.gov/ftp/pro/astro/hadec2altaz.pro *)

decHaLat2xyzAltAz[dec_,ha_,lat_] = Module[{sh,sd,sl,ch,cd,cl},
 sh = Sin[ha];
 ch = Cos[ha];
 sd = Sin[dec];
 cd = Cos[dec];
 sl = Sin[lat];
 cl = Cos[lat];
{-ch*cd*sl + sd*cl, -sh*cd, ch*cd*cl + sd*sl}
]

(* Mathematica convention: ArcTan[x,y] ~ ArcTan[x/y] *)

decHaLat2azAlt[dec_,ha_,lat_] = Module[{r,x,y,z},
 {x,y,z} = decHaLat2xyzAltAz[dec,ha,lat];
 r = Sqrt[1-z^2];
 {ArcTan[x,y],ArcTan[r,z]}
]

(* the rise and set are not necessarily on the same day *)

decLat2haRise[dec_,lat_] = -ArcCos[-Tan[dec]*Tan[lat]]
decLat2haSet[dec_,lat_] = ArcCos[-Tan[dec]*Tan[lat]]

latLst2xyzEarth[lat_,lst_] = 
 lat2earthRadius[lat]*{Sin[lat]*Cos[lst],Sin[lat]*Sin[lst],Cos[lat]}

raDecLatLonAlt2GMST[ra_, dec_, lat_, lon_, alt_] = {
 -lon + ra + ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]],
 -lon + ra - ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]]
};


raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst]

test1912[ra_, dec_, lat_, lon_, gmst_] = 
 raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[2]];

test1913[gmst_] = 
 raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[2]];




raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst]

(* Mathematica takes forever to try to solve this *)

s1717 = Solve[raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[1]] == az, gmst]

(* Mathematica can solve it w/ changing two arg tan to one arg tan *)

s1751 = Solve[
 (raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[1]] /. simptan) == az, 
 gmst]

(* the first solution, without conditional expression, and no C[1] *)

s1753 = s1751[[1,1,2,1]] /. C[1] -> 0

(* as above, with arctan two arg to one arg again, removing lon and
ra, and taking tan; answer is now ArcTan[result]-lon+ra *)

s1756 = Simplify[Tan[s1753+lon-ra /. simptan],conds]

s1806 = s1756 /. {Sqrt[Cos[dec]^4*x_] -> Cos[dec]^2*Sqrt[x]}

s1808 = FullSimplify[s1806 /. {Sin[lat] -> slat, Sin[dec] -> sdec,
          Cos[lat] -> clat, Cos[dec] -> cdec,
          Tan[lat] -> slat/clat, Tan[dec] -> sdec/cdec, Tan[az] -> taz,
          Sec[lat] -> 1/clat, Sec[dec] -> 1/cdec
         }]

s1753/Pi*12 /. 
 {ra -> 0, dec -> 0, lat -> 35*Degree, lon -> 0, az -> 180.*Degree}

(* silly random testing *)

test0 := Module[{ra, dec, lat, lon, alt, gmst, res0, res1},
 {ra, lon} = Table[Random[Real,{-Pi,Pi}], {i,1,2}];
 {dec, lat, alt} = Table[Random[Real,{-Pi/2,Pi/2}], {i,1,3}];
 gmst = raDecLatLonAlt2GMST[ra, dec, lat, lon, alt];
 res0 = raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst[[1]]][[2]];
 res1 = raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst[[2]]][[2]];
(* Return[Chop[{alt, res0, res1}]]; *)
 Return[Chop[{alt-res0, alt-res1, res0-res1}] == {0,0,0}]
]

test0 := Module[{ra, dec, lat, lon, alt, az, gmst0, res0, res1},
 {ra, lon, az} = Table[Random[Real,{-Pi,Pi}], {i,1,3}];
 {dec, lat, alt} = Table[Random[Real,{-Pi/2,Pi/2}], {i,1,3}];
 gmst0 = 

-lon + ra + ArcTan[(Cos[dec]*Cos[lat]*Sin[dec]*Sin[lat]*Tan[az]^2 - 
    Sqrt[Cos[dec]^4 - Cos[dec]^2*Cos[lat]^2*Sin[dec]^2*Tan[az]^2 + 
      Cos[dec]^4*Sin[lat]^2*Tan[az]^2])/(Cos[dec]^2 + 
    Cos[dec]^2*Sin[lat]^2*Tan[az]^2), 
  Sec[dec]*(-(Cos[lat]*Sin[dec]*Tan[az]) + 
    (Cos[dec]^2*Cos[lat]*Sin[dec]*Sin[lat]^2*Tan[az]^3)/
     (Cos[dec]^2 + Cos[dec]^2*Sin[lat]^2*Tan[az]^2) - 
    (Cos[dec]*Sin[lat]*Tan[az]*Sqrt[Cos[dec]^4 - Cos[dec]^2*Cos[lat]^2*
         Sin[dec]^2*Tan[az]^2 + Cos[dec]^4*Sin[lat]^2*Tan[az]^2])/
     (Cos[dec]^2 + Cos[dec]^2*Sin[lat]^2*Tan[az]^2))]
;

 res0 = raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst0][[1]];
 Return[{res0, az}];
]





 








Cos[lat] -> clat, Sin[dec] -> sdec, Sec[dec] -> 1/cdec,
 






s1723 = Solve[{
 (raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[1]] == az) && conds}, 
 gmst, Reals]

s1710 = Solve[
 (raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[1]] /. simptan) == az, 
 gmst]

s1730 = Simplify[
raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[1]] /. simptan, conds]

s1735 = Simplify[Solve[Tan[s1730] == taz, gmst], conds]

s1736 = Simplify[s1735 /. simptan,conds]

s1737 = Simplify[s1736 /. Sqrt[Cos[dec]^4*x_] -> Cos[dec]^2*Sqrt[x],conds]

Simplify[s1737 /. {C[1] -> 0, taz -> Tan[az]},conds]







s1714 = Simplify[s1710[[1,1,2,1]] /. simptan, conds]

s1714 /. {C[1] -> 0, Sqrt[Cos[dec]^4*x_] -> Cos[dec]^2*Sqrt[x]}




s1659 = raDecLatLonGMST2azAlt[ra, dec, lat, lon, gmst][[1]] /. simptan

s1700 = s1659[[2,1]]

FullSimplify[Solve[s1700 == taz, gmst] /. simptan,conds]

TODO: min az/max az, trivial culm, max el, min el, then az2el and vv


temp0514 = raDecLatLonAlt2GMST[ra, dec, lat, lon, alt][[1]]
temp0515 = raDecLatLonAlt2GMST[ra, dec, lat, lon, alt][[2]]

raDecLatLonGMST2azAlt[ra, dec, lat, lon, temp0514][[1]]
raDecLatLonGMST2azAlt[ra, dec, lat, lon, temp0515][[1]]

temp0518 = FullSimplify[raDecLatLonAlt2GMST[ra, dec, lat, lon, 0], conds]

FullSimplify[raDecLatLonGMST2azAlt[ra, dec, lat, lon, temp0518[[1]]][[1]], 
 conds]

AstronomicalData["Moon", {"Declination", {2018,2,4}}]

Plot[AstronomicalData["Moon", {"Declination", unix2date[t]}], 
 {t, 1420070400, 1735689600}]

t0533 = Table[AstronomicalData["Moon", {"Declination", unix2Date[t]}],
 {t, 1420070400, 1735689600, 86400}];

t0533 = Table[AstronomicalData["Moon", {"Declination", unix2Date[t]}],
 {t, 1514764800, 1546300800, 86400/24}];


(* moon declinations *)

t0649 = ReadList["/home/user/20180204/decs.txt"]

t0654 = ReadList["/home/user/20180204/ras.txt"]

t0655 = Mod[difference[t0654], 2*Pi]

t0655 = difference[Take[t0654,8000]];

 




TODO: based on lat alt conflict, should I use el instead?


