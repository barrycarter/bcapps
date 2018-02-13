TODO: answer here!



temp0939[dec_, lat_] = (decLatAlt2TimeAboveAlt[dec,lat,-50/60*Degree] - 
decLatAlt2TimeAboveAlt[dec,lat,-18/60*Degree])/2;

temp0946[dec_, lat_] = D[temp0939[dec,lat], lat];

Plot3D[temp0939[dec,lat], {dec,-23*Degree,23*Degree}, {lat,
-60*Degree, 60*Degree}]

Plot[temp0939[23*Degree, lat],{lat,-60*Degree, 60*Degree}]

Plot[temp0939[-23*Degree, lat],{lat,-60*Degree, 60*Degree}]

Plot[temp0939[0*Degree, lat],{lat,-60*Degree, 60*Degree}]

Plot3D[temp0946[dec,lat], {dec,-23*Degree,23*Degree}, {lat,
-60*Degree, 60*Degree}]

Plot[temp0946[23*Degree, lat],{lat,-60*Degree, 60*Degree}]







temp1044 = ReadList["/mnt/villa/user/20180205/solar.txt", "Number",
 "RecordLists" -> True];

temp0917 = Transpose[temp1044][[4]];

x = number of hours since 11am on 1 Jan 2000 (hmmmm)



FromDate[FromJulianDate[jd][[1]]]

doy[jd_] := Module[{temp1},
 temp1 = FromJulianDate[jd][[1]];
 Return[Round[(FromDate[temp1] - FromDate[{temp1[[1]], 1, 1}])/86400, 1/24]];
]

temp1108 = Table[{doy[i[[2]]], i[[4]]}, {i, temp1044}];

temp0912 = Gather[temp1108, #1[[1]] == #2[[1]] &];




 temp1 = Take[FromJulianDate[Rationalize[jd,0]][[1]],4];
 Return[Rationalize[1/2+DateDifference[{temp1[[1]], 1, 1}, temp1][[1]]]];
];

doy[jd_] := Module[{temp1},
 temp1 = Take[FromJulianDate[Rationalize[jd,0]][[1]],4];
 Return[Rationalize[1/2+DateDifference[{temp1[[1]], 1, 1}, temp1][[1]]]];
];




 




 RecordLists -> True,  WordSeparators -> {" "}, TokenWords -> {" "}];


temp1044 = ReadList["/mnt/villa/user/20180205/solar.txt", "Record", 
 RecordLists -> True,  WordSeparators -> {" "}, TokenWords -> {" "}];



, RecordLists -> True,






To an accuracy of $0.05 {}^{\circ}$, the Sun's average declination at 12h UT on the nth day of the year for the years 2000-2099 inclusive is:

$
  0.0697459 \sin \left(\frac{\pi  n}{183}\right)+0.000529317 \sin \left(\frac{2
    \pi  n}{183}\right)+0.00131974 \sin \left(\frac{\pi  n}{61}\right)-0.400316
    \cos \left(\frac{\pi  n}{183}\right)-0.0060873 \cos \left(\frac{2 \pi 
    n}{183}\right)-0.00239961 \cos \left(\frac{\pi  n}{61}\right)+0.00576798
$

where all angles are measured in radians.

I obtained the formula above via curve fitting because I was unhappy with Wikipedia's [solar declination formulas](https://en.wikipedia.org/wiki/Position_of_the_Sun#Calculations), and believe the "more accurate" formula is actually incorrect.

My formula is unnecessarily precise, because there is no exact formula mapping day of year to solar declination. Example:

  - On the 240th day of 2017 (August 28th, Julian Day 2457994), the sun's declination at 12h UT is 0.168035 radians (9.6277 degrees).

  - On the 240th day of 2018 (August 28th, Julian Day 2458359), the sun's declination at 12h UT is 0.169625 radians (9.7188 degrees).

  - On the 240th day of 2019 (August 28th, Julian Day 2458724), the sun's declination at 12h UT is 0.171204 radians (9.80927 degrees).

  - On the 240th day of 2020 (August 27th [because 2020 is a leap year], Julian Day 2459089), the sun's declination at 12h UT is 0.172757 radians (9.89825 degrees).

That's a range of 0.27055 degrees over just 4 years.

A celestial object reaches altitude `alt` at:

$
   \cos ^{-1}(\sin (\text{alt}) \sec (\text{dec}) \sec (\text{lat})-\tan
    (\text{dec}) \tan (\text{lat}))
$

after it culminates, where all angles are in radians. Notes:

  - The result is in radians, where $2 \pi$ radians is a sidereal day.

  - If the value inside the arc-cosine function is greater than 1 or less than -1, the object never reaches the given altitude.

  - The Sun starts setting when it's lower limb touches the horizon and finishes setting when  it's upper limb sinks below the horizon.

  - The Sun's angular radius is 16 minutes of arc, so it starts setting when the center of the Sun has angular altitude of 16 minutes and finishes setting when the altitude of the Sun's center is -16 minutes.

  - Because of refraction, the Sun appears 34 minutes of arc higher than it's geometric position. The actual value of refraction varies with atmospheric conditions (and this variation can be considerable), but 34 minutes is the accepted value for computing sunrise and sunset. Therefore, the Sun starts setting when it's geometric center is at 16-34 or -18 minutes of arc, and finishes setting when it's at -16-34 or -50 minutes of arc.

  - To find how long it takes to set, we subtract the time when it's geometric position is -18 minutes of arc from when it's geometric position is at -50 minutes of arc. Combining this with the declination formula above, this yields:




TODO: twilights

sidereal

TODO: refraction not contcats

TODO: west of GMT


TODO: time in radians

TODO: apprxomation


TODO: my other ugly formula URL
sidereal to solar conversion




REF: http://aa.usno.navy.mil/jdconverter?ID=AA&jd=2457994


TODO: variance



how I got these numbers

bc-equator-dump 10 399 2000 2100
mention bc-astro-formulas.m mention


dec avg is not 0!

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
 2*ArcCos[Sec[dec]*Sec[lat]*Sin[alt] - Tan[dec]*Tan[lat]];

decLatAlt2az[dec_, lat_, alt_] = {
 ArcCos[Sec[alt]*Sec[lat]*Sin[dec] - Tan[alt]*Tan[lat]],
 -ArcCos[Sec[alt]*Sec[lat]*Sin[dec] - Tan[alt]*Tan[lat]]};

(* solar declination at 12h UT on nth day of year, 2000-2099 *)

doy2decSun[doy_] = 
0.005767978633879778 - 0.4003158126006976*Cos[(doy*Pi)/183] - 
 0.006087303223362971*Cos[(2*doy*Pi)/183] - 0.002399606972263487*
  Cos[(doy*Pi)/61] + 0.06974587377531068*Sin[(doy*Pi)/183] + 
 0.0005293173364751269*Sin[(2*doy*Pi)/183] + 
 0.0013197353309006461*Sin[(doy*Pi)/61];

conds = {
 -Pi < ra < Pi, -Pi < lon < Pi, -Pi < gmst < Pi, -Pi < az < Pi,
 -Pi/2 < dec < Pi/2, -Pi/2 < lat < Pi/2, -Pi/2 < alt < Pi/2
};

</formulas>
