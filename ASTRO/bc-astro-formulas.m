(*

<docs>

Caveats: we assume fixed ra, dec, lat, lon

Measurement units: km, radians

Time units used:

  - mjd: modified Julian date [number of days since 2000 January 1, at 12h UT]
  - gmst: Greenwich mean sidereal time (radians)
  - lst: local sidereal time (radians)
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

https://astronomy.stackexchange.com/questions/24598/how-to-calculate-the-maximum-and-minimum-solar-azimuth-at-a-given-location

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
  - distang: angular distance
  - distlen: length distance
  - cons: this value when treated as a constant
  
</docs>

<formulas>



</formulas>

<sources>


</sources>

<work>

conds={0 <= lst <= 2*Pi, 0 <= ra <= 2*Pi, -Pi <= dec <= Pi, -Pi <= lat <= Pi};

(* simplifications that dont always apply but can be useful *)

simptan = {ArcTan[x_,y_] -> ArcTan[y/x]}

FullSimplify[HADecLat2azEl[gmst+lon-ra, dec, lat],conds]

raDecLatLonGMST2azEl[ra_, dec_, lat_, lon_, gmst_] = 
 {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat], 
  -(Cos[dec]*Sin[gmst + lon - ra])], 
 ArcTan[Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[gmst + lon - ra]^2], 
  Cos[dec]*Cos[lat]*Cos[gmst + lon - ra] + Sin[dec]*Sin[lat]]}


TODO: below doesnt use lon and should -- gmst not lst

lstRaDecLatLon2azEl[lst_, ra_, dec_, lat_, lon_] = 
{ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[lst - ra]*Sin[lat], 
  -(Cos[dec]*Sin[lst - ra])], 
 ArcTan[Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[lst - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[lst - ra]^2], Cos[dec]*Cos[lat]*Cos[lst - ra] + 
   Sin[dec]*Sin[lat]]}

Solve[lstRaDecLatLon2azEl[lst,ra,dec,lat,lon][[2]] == 0, lst]


lstRaDecLatLon2azEl[lst, lst, dec, lat, lon]

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

decHaLat2azEl[dec_,ha_,lat_] = Module[{r,x,y,z},
 {x,y,z} = decHaLat2xyzAltAz[dec,ha,lat];
 r = Sqrt[1-z^2];
 {ArcTan[x,y],ArcTan[r,z]}
]

(* the rise and set are not necessarily on the same day *)

decLat2haRise[dec_,lat_] = -ArcCos[-Tan[dec]*Tan[lat]]
decLat2haSet[dec_,lat_] = ArcCos[-Tan[dec]*Tan[lat]]

latLst2xyzEarth[lat_,lst_] = 
 lat2earthRadius[lat]*{Sin[lat]*Cos[lst],Sin[lat]*Sin[lst],Cos[lat]}


