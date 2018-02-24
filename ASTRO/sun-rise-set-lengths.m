TODO: answer here!

(* from https://mathematica.stackexchange.com/questions/165903/how-to-approximate-specific-2-dimensional-function-general-tips?noredirect=1#comment438453_165903 *)

f[lat_] = {1, lat^2, lat^4}

g[n_] = {1, Cos[2*Pi*n/183], Sin[2*Pi*n/183]}

f[lat_] = {1, Exp[lat]}

g[n_] = {1, Cos[2*Pi*n/183], Sin[2*Pi*n/183], Cos[2*Pi*n/366], Sin[2*Pi*n/366],
 Sin[2*Pi*n/122], Cos[2*Pi*n/122]}

f[lat_] = Table[lat^i,{i,0,2}]

g[n_] = Table[n^i, {i,0,2}]

h = Flatten[Outer[Times, f[lat], g[n]]]

M = NIntegrate[Outer[Times, h, h], {n, 0, 366}, {lat,
-Pi/3,Pi/3},PrecisionGoal -> 5, AccuracyGoal -> 4]

r = NIntegrate[h temp1942[n, lat], {n, 0, 366}, {lat,
-Pi/3,Pi/3},PrecisionGoal -> 5, AccuracyGoal -> 4]

c=Inverse[M].r

temp0829[n_, lat_] = c.h

ContourPlot[temp0829[n,lat*Degree] - temp1942[n,lat*Degree],
{n,0.5,366.5},{lat,-60,60}, ImageSize -> {800,600},
Contours -> 64, ColorFunction -> Hue, PlotLegends -> True]

ContourPlot[
(temp1942[n,lat*Degree] - temp0829[n,lat*Degree])/temp1942[n,lat*Degree],
{n,0.5,366.5},{lat,-60,60}, ImageSize -> {800,600},
Contours -> 64, ColorFunction -> Hue, PlotLegends -> True]

ContourPlot[temp1942[n,lat*Degree],
{n,0.5,366.5},{lat,-60,60}, ImageSize -> {800,600},
Contours -> 64, ColorFunction -> Hue, PlotLegends -> True]

ContourPlot[temp1942[n,lat*Degree],
{n,0.5,366.5},{lat,-65,65}, ImageSize -> {800,600},
Contours -> 64, ColorFunction -> Hue, PlotLegends -> True]

(* length of sunrise/sunset, in seconds *)

temp1942[doy_, lat_] = 
 N[(decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -5/6*Degree] -
 decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -18/60*Degree])/Pi*12*3600/2];

(* length of day, in hours *)

temp2159[doy_, lat_] = 
 N[decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -5/6*Degree]]/Pi*12

(* length of civil twilight, in minutes *)

temp2200[doy_, lat_] = 
 N[(decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -6*Degree] -
 decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -5/6*Degree])/Pi*12*60/2];

(* length of nautical twilight, in minutes *)

temp2201[doy_, lat_] = 
 N[(decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -12*Degree] -
 decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -6*Degree])/Pi*12*60/2];

(* length of astronomical twilight, in minutes *)

temp2202[doy_, lat_] = 
 N[(decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -18*Degree] -
 decLatAlt2TimeAboveAlt[doy2decSun[doy], lat, -12*Degree])/Pi*12*60/2];



Plot[temp1942[doy,60*Degree],{doy,0.5,366.5}]

tab2009[lat_] := tab2009[lat] = 
 Table[{doy, temp1942[doy, lat*Degree]}, {doy, 0.5, 366.5, 1/24}]

int2009[lat_] := int2009[lat] = Interpolation[tab2009[lat]]

est2009[lat_] := est2009[lat] = Function[ x, 
 Evaluate[Fit[tab2009[lat],
 {1, Sin[x/183*2*Pi], Cos[x/183*2*Pi], Sin[x/366*2*Pi], Cos[x/366*2*Pi]}, 
 x]]]

Plot[int2009[40][x] - est2009[40][x], {x,0.5,366.5}]

Plot[int2009[30][x] - est2009[30][x], {x,0.5,366.5}]

Plot[int2009[64][x] - est2009[64][x], {x,0.5,366.5}]

const2009[lat_] := NIntegrate[temp1942[doy, lat*Degree], {doy, 0.5, 366.5}]/366

cosconst2009[lat_] := NIntegrate[
 (temp1942[doy, lat*Degree]-const2009[lat])*
 Cos[doy/183*2*Pi], {doy, 0.5, 366.5}]/366

sinconst2009[lat_] := NIntegrate[
 (temp1942[doy, lat*Degree]-const2009[lat])*
 Sin[doy/183*2*Pi], {doy, 0.5, 366.5}]/366

power2009[doy_, lat_] = 
 Normal[N[Series[Normal[N[Series[temp1942[doy,lat], {lat,0,4}]] ],
 {doy,183,4}]]]

derv2009[doy_, lat_] = D[temp1942[doy,lat], doy]

derv2009d2[doy_, lat_] = D[temp1942[doy,lat], doy, doy]

derv2009d3[doy_, lat_] = D[temp1942[doy,lat], doy, doy, doy]

ContourPlot[temp1942[doy,lat*Degree],{doy,0.5,366.5}, 
 {lat,-60, 60}, ImageSize -> {800,600}, Contours -> 64, ColorFunction -> Hue,
 PlotLegends -> True]










dec[n_] := dec[n] = Mean[Table[AstronomicalData["Sun", {"Declination", 
 DatePlus[{y, 1, 1}, n-1]}], {y,2001,2036}]][[1]]*Degree


temp0939[dec_, lat_] =
((decLatAlt2TimeAboveAlt[dec,lat*Degree,-50/60*Degree] -
decLatAlt2TimeAboveAlt[dec,lat*Degree,-18/60*Degree])/2)/Pi*12*3600;

temp0904[dec_, lat_] = N[Normal[Series[
 Normal[Series[temp0939[dec,lat],{dec,0,6}]],
{lat,0,6}
]]]

temp0924[n_, lat_] = N[Normal[Series[
 Normal[Series[temp0939[doy2decSun[n],lat],{n,0,3}]],
{lat,0,3}
]]]

temp0924[n_, lat_] = N[Normal[Series[
 Normal[Series[temp0939[doy2decSun[n],lat],{n,183,16}]],
{lat,0,16}
]]]



Plot3D[temp0939[dec,lat], {dec,-24*Degree,24*Degree}, {lat,
-60*Degree, 60*Degree}]

Plot3D[temp0904[dec,lat], {dec,-24*Degree,24*Degree}, {lat,
-60*Degree, 60*Degree}]

Plot3D[temp0904[dec,lat]-temp0939[dec,lat], {dec,-24*Degree,24*Degree}, {lat,
-90*Degree, 90*Degree}]

ContourPlot[temp0904[dec,lat]-temp0939[dec,lat], {dec,-24*Degree,24*Degree},
 {lat, -90, 90}, PlotLegends -> True, ColorFunction -> Hue,
 Contours -> 64]

ContourPlot[temp0924[n,lat]-temp0939[doy2decSun[n],lat], 
 {lat,-90,90},
 {n, 0.5, 366.5}, PlotLegends -> True, ColorFunction -> Hue,
 Contours -> 64]

ContourPlot[temp0924[n,lat],
 {n, 0.5, 366.5},  {lat,-90,90}, PlotLegends -> True, ColorFunction -> Hue,
 Contours -> 64]






f0850[lat_] = (decLatAlt2TimeAboveAlt[dec[1], lat, -50/60*Degree] -
 decLatAlt2TimeAboveAlt[dec[1], lat, -18/60*Degree])/2



tab0830 = Table[{lat, decLatAlt2TimeAboveAlt[dec[1], lat, -50/60*Degree]},
 {lat,-90*Degree,90*Degree,0.1*Degree}]




temp1523 = Table[{n,dec[n]},{n, 1/2, 366+1/2, 1/24}];
temp1523 = Table[{n,dec[n]},{n, 1/2, 366+1/2, 1/12}];


Plot[temp0939[dec, 40*Degree], {dec,-24*Degree,24*Degree}]


temp0946[dec_, lat_] = D[temp0939[dec,lat], lat];

Plot3D[temp0939[dec,lat], {dec,-23*Degree,23*Degree}, {lat,
-60*Degree, 60*Degree}]

Plot[temp0939[23*Degree, lat],{lat,-60*Degree, 60*Degree}]

Plot[temp0939[-23*Degree, lat],{lat,-60*Degree, 60*Degree}]

Plot[temp0939[0*Degree, lat],{lat,-60*Degree, 60*Degree}]

Plot3D[temp0946[dec,lat], {dec,-23*Degree,23*Degree}, {lat,
-60*Degree, 60*Degree}]

Plot[temp0946[23*Degree, lat],{lat,-60*Degree, 60*Degree}]





(* solar3 is trimmed for 2001-2036 inclusive; solar4 from 2017-2020 *)

temp1044 = ReadList["/mnt/villa/user/20180205/solar4.txt", "Number",
 "RecordLists" -> True];

temp0917 = Transpose[temp1044][[4]];

x = number of hours since 11am on 1 Jan 2000 (hmmmm)



FromDate[FromJulianDate[jd][[1]]]

doy[jd_] := Module[{temp1},
 temp1 = FromJulianDate[jd][[1]];
 Return[1/2+
 Round[(FromDate[temp1] - FromDate[{temp1[[1]], 1, 1}])/86400, 1/24]];
]

temp1108 = Table[{doy[i[[2]]], i[[4]]}, {i, temp1044}];

temp0912 = Gather[temp1108, #1[[1]] == #2[[1]] &];

Table[temp0918[Transpose[i][[1,1]]] = Mean[Transpose[i][[2]]], {i, temp0912}];

temp1925 = Table[{Transpose[i][[1,1]], Mean[Transpose[i][[2]]]}, {i,temp0912}];

temp1926[x_] = Interpolation[temp1925][x]

temp2120=Total[Table[(a0+a1*Cos[a2*i[[1]]-a3] - i[[2]])^2, {i,temp1925}]]

f2134[x_] = a0 + a1*Cos[x/366*2*Pi-a2] + a3*Cos[x/183*2*Pi-a4]

temp2135 = Total[Table[(f2134[i[[1]]] - i[[2]])^2, {i, temp1925}]]

temp2136 = NMinimize[temp2135, {a0, a1, a2, a3, a4}]

f2136[x_] = f2134[x] /. temp2136[[2]]

Plot[{temp1926[x], f2136[x]}, {x,0.5,366.5}]

good to 0.003 radians or 0.17 degrees

f2138[x_] = a0 + a1*Cos[x/366*2*Pi-a2] + a3*Cos[x/183*2*Pi-a4] + 
 a5*Cos[x/122*2*Pi-a6]

temp2138 = Total[Table[(f2138[i[[1]]] - i[[2]])^2, {i, temp1925}]]

temp2139 = NMinimize[temp2138, {a0, a1, a2, a3, a4, a5, a6}]

f2140[x_] = f2138[x] /. temp2139[[2]]

Plot[{temp1926[x], f2140[x]}, {x,0.5,366.5}]

temp2125=Total[Table[(a0+a1*Cos[i[[1]]/366*2*Pi-a3] - i[[2]])^2, {i,temp1925}]]

temp2121 = NMinimize[temp2125, {a0,a1,a3}]

f2118[x_] = a0+a1*Cos[x/366*2*Pi-a3] /. temp2121[[2]]

Plot[{temp1926[x], f2118[x]}, {x,0.5,366.5}]




f1928[x_] = Fit[temp1925, {1, Sin[x/366*2*Pi], Cos[x/366*2*Pi]}, x]

Plot[{temp1926[x], f1928[x]}, {x,0.5,366.5}]

Plot[{temp1926[x]-f1928[x]}, {x,0.5,366.5}]

f1931[x_] = Fit[temp1925, {1, x, Sin[x/366*2*Pi], Cos[x/366*2*Pi],
 Sin[x/183*2*Pi], Cos[x/183*2*Pi]}, x]

f1934[x_] = Fit[temp1925, {1, Sin[x/366*2*Pi], Cos[x/366*2*Pi],
 Sin[x/183*2*Pi], Cos[x/183*2*Pi]}, x]

f1934[x_] = Fit[temp1925, {1, Sin[x/366*2*Pi], Cos[x/366*2*Pi],
 Sin[x/183*2*Pi], Cos[x/183*2*Pi], Sin[x/122*2*Pi], Cos[x/122*2*Pi]}, x]

Plot[{temp1926[x]-f1934[x]}, {x,0.5,366.5}]



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






To an accuracy of $0.05 {}^{\circ}$, the Sun's average declination at 12h UT on the nth day of the year for the years 2000-2099 (*** NO LONGER TRUE) inclusive is:

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

(* solar declination at 12h UT on nth day of year, 2000-2099 *)

doy2decSun[doy_] = 
0.005767978633879778 - 0.4003158126006976*Cos[(doy*Pi)/183] - 
 0.006087303223362971*Cos[(2*doy*Pi)/183] - 0.002399606972263487*
  Cos[(doy*Pi)/61] + 0.06974587377531068*Sin[(doy*Pi)/183] + 
 0.0005293173364751269*Sin[(2*doy*Pi)/183] + 
 0.0013197353309006461*Sin[(doy*Pi)/61];

<formulas>

(* solar declination hour by hour for 2017-2020, 1 = Jan 1 12h UT *)

doy2decSun[doy_] = 
0.0057829543264974964 - 0.40641386702350013*
  Cos[0.17591034793235705 + (doy*Pi)/183] - 0.006120371238861089*
  Cos[0.09594426510756572 + (2*doy*Pi)/183] - 
 0.0027408604099180994*Cos[0.5134241402204166 + (doy*Pi)/61]

raDecLatLonGMST2azAlt[ra_, dec_, lat_, lon_, gmst_] = 
 {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat], 
  -(Cos[dec]*Sin[gmst + lon - ra])], 
 ArcTan[Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[gmst + lon - ra]^2], 
  Cos[dec]*Cos[lat]*Cos[gmst + lon - ra] + Sin[dec]*Sin[lat]]};

raDecLatLonAlt2GMST[ra_, dec_, lat_, lon_, alt_] = {
 -lon + ra + ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]],
 -lon + ra - ArcCos[Sec[dec] Sec[lat] Sin[alt] - Tan[dec] Tan[lat]]
};

decLatAlt2TimeAboveAlt[dec_, lat_, alt_] = 
 2*ArcCos[Sec[dec]*Sec[lat]*Sin[alt] - Tan[dec]*Tan[lat]];

decLatAlt2az[dec_, lat_, alt_] = {
 ArcCos[Sec[alt]*Sec[lat]*Sin[dec] - Tan[alt]*Tan[lat]],
 -ArcCos[Sec[alt]*Sec[lat]*Sin[dec] - Tan[alt]*Tan[lat]]};

conds = {
 -Pi < ra < Pi, -Pi < lon < Pi, -Pi < gmst < Pi, -Pi < az < Pi,
 -Pi/2 < dec < Pi/2, -Pi/2 < lat < Pi/2, -Pi/2 < alt < Pi/2,
 0.5 < doy < 366.5
};

</formulas>

(*

Subject: How to approximate specific 2 dimensional function + general tips?

<pre><code>

(* this formula yields the length of sunrise/sunset on the nth day of
the year (0.5 <= n <= 366.5) for latitude lat, where lat is measured
in radians *)

temp1942[n_, lat_] = 

6875.493541569879*
 (2.*ArcCos[-0.014543897651582656*Sec[lat]*Sec[0.005782961777094692 - 
        0.4001419318234436*Cos[0.017167172970436028*n] - 
        0.0060922154967620835*Cos[0.034334345940872056*n] - 
        0.002387468786938206*Cos[0.05150151891130809*n] + 
        0.0711242550022214*Sin[0.017167172970436028*n] + 
        0.0005863132618294766*Sin[0.034334345940872056*n] + 
        0.0013462049383894524*Sin[0.05150151891130809*n]] - 
     1.*Tan[lat]*Tan[0.005782961777094692 - 0.4001419318234436*
         Cos[0.017167172970436028*n] - 0.0060922154967620835*
         Cos[0.034334345940872056*n] - 0.002387468786938206*
         Cos[0.05150151891130809*n] + 0.0711242550022214*
         Sin[0.017167172970436028*n] + 0.0005863132618294766*
         Sin[0.034334345940872056*n] + 0.0013462049383894524*
         Sin[0.05150151891130809*n]]] - 
  2.*ArcCos[-0.00523596383141958*Sec[lat]*Sec[0.005782961777094692 - 
        0.4001419318234436*Cos[0.017167172970436028*n] - 
        0.0060922154967620835*Cos[0.034334345940872056*n] - 
        0.002387468786938206*Cos[0.05150151891130809*n] + 
        0.0711242550022214*Sin[0.017167172970436028*n] + 
        0.0005863132618294766*Sin[0.034334345940872056*n] + 
        0.0013462049383894524*Sin[0.05150151891130809*n]] - 
     1.*Tan[lat]*Tan[0.005782961777094692 - 0.4001419318234436*
         Cos[0.017167172970436028*n] - 0.0060922154967620835*
         Cos[0.034334345940872056*n] - 0.002387468786938206*
         Cos[0.05150151891130809*n] + 0.0711242550022214*
         Sin[0.017167172970436028*n] + 0.0005863132618294766*
         Sin[0.034334345940872056*n] + 0.0013462049383894524*
         Sin[0.05150151891130809*n]]])

(* it is 184 terms long in TreeForm *)

In[158]:= LeafCount[TreeForm[temp1942[n,lat]]]

Out[158]= 184

(*

I'm looking for an approximation that is significantly shorter, and
still reasonably accurate for -Pi/3 <= lat <= Pi/3; the function blows
up as Abs[lat] approaches Pi/2, so the approximation need not be
accurate when Abs[lat] > Pi/3

The approximation should not be a Piecewise function (like FindFormula
tends to yield, and which Interpolate generates by design), and should
be a reasonably easy to calculate "rule of thumb".

The (extremely ugly) work I've done so far is at:

https://github.com/barrycarter/bcapps/blob/master/ASTRO/sun-rise-set-lengths.m

https://github.com/barrycarter/bcapps/blob/master/ASTRO/bc-astro-formulas.m

I'm also looking for general tips on how to approximate a 2
dimensional function that I can evaluate at any point. I've looked
at most of the functions listed on
http://reference.wolfram.com/language/FunctionApproximations/tutorial/FunctionApproximations.html
by fixing one value in my function (usually 'n'), and then trying to
find a pattern to the approximating functions. This does not work
well.

My goal with this specific function is to answer
https://astronomy.stackexchange.com/questions/24304/expression-for-length-of-sunrise-sunset-as-function-of-latitude-and-day-of-year
more succinctly than the current answer, but more generally to provide
good approximations to other (mostly astronomical) formulas that have
no closed form.

*)

https://astronomy.stackexchange.com/questions/12824/how-long-does-a-sunrise-or-sunset-take

(*

EDIT: This is to reply to @ulrich-neumann but is too long to be a comment:

***edit wording above



To explain my confusion, I'll use a simpler example (and use simpler, non-Mathematica, notation):

  - I want to approximate a given g(x) from x=0 to x=1 by three given functions f1, f2, and f3.

  - In other words, I believe `g(x) ~ a1 f1(x) + a2 f2(x) + a3 f3(x)`, for constants a1, a2, and a3.

  - Ideally, I'd minimize the integral of `|g(x) - (a1 f1(x) + a2 f2(x) + a3 f3(x))|` from 0 to 1.

  - However, if I consider bigger differences to be proportionally more important, and to make things simpler, I'll minimize the square of the difference, `(g(x) - (a1 f1(x) + a2 f2(x) + a3 f3(x)))^2`, although [this will yield a different answer](https://stats.stackexchange.com/questions/147001/is-minimizing-squared-error-equivalent-to-minimizing-absolute-error-why-squared)

  - A big advantage of using the square of the difference is that I can refactor it as: `g(x)^2 - 2g(x)(a1 f1(x) + a2 f2(x) + a3 f3(x)) + (a1 f1(x) + a2 f2(x) + a3 f3(x))^2` and then integrate term by term.

  - If we allow `a = {a1,a2,a3}` and `f = {f1[x], f2[x], f3[x]}`, we have `a.f = a1 f1(x) + a2 f2(x) + a3 f3(x)` and 

 can see that `a1 f1(x) + a2 f2(x) + a3 f3(x)` has a very "matrixy" feel, 



In[20]:= f[x_] = a1*f1[x] + a2*f2[x] + a3*f3[x]


another attempt to figure out re linear combos

temp1647 = 
Flatten[Outer[Times,{1, lat^2, lat^4},{1, Cos[2*Pi*n/183], Sin[2*Pi*n/183]}]]

temp1648[n_,lat_] = Total[Table[a[i]*temp1647[[i]],{i,1,Length[temp1647]}]]

temp1649[n_,lat_] = (temp1942[n,lat]-temp1648[n,lat])^2

temp1707 = Expand[(temp1942[n,lat]-temp1648[n,lat])^2]

temp1711[i_] := temp1711[i] = Integrate[temp1707[[i]], {n, 0.5,
366.5}, {lat, -60*Degree, 60*Degree}]

t2031 = Flatten[Table[{doy, lat, temp1942[doy,lat]}, {doy,0.5, 366.5,
0.5},{lat, -60*Degree, 60*Degree, 1*Degree}],1];

Fit[t2031, temp1647, {n, lat}]


temp1708 = 
Table[Integrate[temp1707[[i]], {n, 0.5, 366.5}, {lat, -60*Degree, 60*Degree}],
 {i, 1, Length[temp1707]}]

Integrate[temp1649[n,lat], {n,0.5,366.5}, {lat, -60*Degree, 60*Degree}]



Integrate[(temp1942[n,lat] - temp1648[n,lat])^2,
 {n,0.5,366.5}, {lat, -60*Degree, 60*Degree}]


Subject: How to tell NIntegrate to use linearity for constants?

I'm performing a definite integral on a sum of 66 fairly complicated
terms. Sample term + integral (`a[2]` is a constant):

<pre><code>

temp1733[n_, lat_] = 
-27501.974166279517*a[2]*
 ArcCos[-0.014543897651582656*Sec[lat]*
   Sec[0.005782961777094692 - 0.4001419318234436*Cos[0.017167172970436028*n] - 
      0.0060922154967620835*Cos[0.034334345940872056*n] - 
      0.002387468786938206*Cos[0.05150151891130809*n] + 
      0.0711242550022214*Sin[0.017167172970436028*n] + 
      0.0005863132618294766*Sin[0.034334345940872056*n] + 
      0.0013462049383894524*Sin[0.05150151891130809*n]] - 
   1.*Tan[lat]*Tan[0.005782961777094692 - 0.4001419318234436*
       Cos[0.017167172970436028*n] - 0.0060922154967620835*
       Cos[0.034334345940872056*n] - 0.002387468786938206*
       Cos[0.05150151891130809*n] + 0.0711242550022214*
       Sin[0.017167172970436028*n] + 0.0005863132618294766*
       Sin[0.034334345940872056*n] + 0.0013462049383894524*
       Sin[0.05150151891130809*n]]]*Cos[(2*n*Pi)/183]

temp1734 = Integrate[temp1733[n,lat], {n, 0.5, 366.5}, {lat,
 -60*Degree, 60*Degree}]

</code></pre>

On my machine, the definite integral above times out. Since almost all my values are numerical, I'd like to use `NIntegrate`, but can't, because `a[2]` isn't a numerical value. Of course, in this case, I can simply do:

<pre><code>

a[2]*NIntegrate[temp1733[n,lat]/a[2], {n, 0.5, 366.5}, {lat, 
 -60*Degree, 60*Degree}] 

</code></pre>

to get the answer (it happens to be `-18229.40312917879*a[2]` in this case).

However, I don't want to have to look at each of my terms to factor out the constants.

Is there any way I can tell `NIntegrate` to use linearity of integration for constants? I understand why `NIntegrate` can't handle more deeply nested constants (see https://mathematica.stackexchange.com/questions/159243/), but it seems constants used in a purely linear way should work.

I did try things like `Coefficient` and `CoefficientList`, but they won't work in my case because the function I'm using isn't a polynomial in my constants. Even if I can't coerce `NIntegrate` to handle my functions, there must be a way to separate out and then rejoin the constant parts?

This question is a followup of sorts to the answer https://mathematica.stackexchange.com/a/165937/1722 which shows a more complicated (in my opinion) way to solve a similar problem.

(Sum[a[i]*f[i], {i,1,5}]-f)^2

(Sum[a[i]*f[i], {i,1,n}]-f)^2 - 
Sum[a[i]*a[j]*f[i]*f[j], {i,1,n}, {j,1,n}] -
-2*Sum[f*a[i]*f[i], {i,1,n}] - f^2

(f[x]- Sum[a[i]*f[i], {i,1,n}])^2 

TODO: note using single variable here, could be any region

Integrate[(f[x]- Sum[a[i]*f[i][x], {i,1,n}])^2, x]

Integrate[Sum[a[i]*a[j]*f[i][x]*f[j][x], {i,1,n}, {j,1,n}], x]




((Sum[a[i]*f[i], {i,1,n}]-f)^2 - Sum[a[i]*a[j]*f[i]*f[j], {i,1,n}, {j,1,n}]) /.
 n -> 5

Fit[x^2 + y^2, {Sqrt[x], Sqrt[y]}, {x,y}]


t2058 = Collect[(f - Sum[a[i]*f[i],{i,1,4}])^2, _a]



