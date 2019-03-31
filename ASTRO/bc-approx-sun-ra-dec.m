(*

<writeup>

On "average", the Sun transits at local mean solar noon, which occurs at $(\left(\frac{\text{lon}}{15}+12\right) \bmod 24)$ UTC as measured in hours, where $\text{lon}$ is your longitude expressed in degrees, with western longitudes given as negative numbers.

We can get much better precision by adjusting this number using the [Equation of Time](https://en.wikipedia.org/wiki/Equation_of_time)




</writeup>

*)

(* work below 26 Mar 2019 *)

(* math2 bc-astro-formulas.m *)

(* TODO: make length of year more accurate *)

loy = 24*365.2425;

decf = Interpolation[decs]

n = 4;

f[x_] = c[0] + Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x], {i,1,n}];

f[x_] = c[0] + Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x] 
 + e[i]*(x-Length[decs]/2)*Cos[h[i] - i*2*Pi/loy*x], {i,1,n}];

f[x_] = c[0] + e[1]*(x-Length[decs]/2)*Cos[h[1]-1*2*Pi/loy*x] + 
        Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x], {i,1,n}];

vars = Flatten[{c[0], Table[{c[i], d[i], e[i], h[i]}, {i,1,n}]}];

vars = Flatten[{e[1], h[1], c[0], Table[{c[i], d[i]}, {i,1,n}]}];

ff = FindFit[decs, f[x], vars, x];

g[x_] = N[f[x] /. ff];

Plot[{(g[x]-decf[x])/Degree*60}, {x, 1, Length[decs]}, PlotRange->All]

Plot[ ((g[x]-decf[x])/Degree*60) / (x-Length[decs]/2), 
 {x, 1, Length[decs]}, PlotRange->All]

(* above = w/in 30' of arc for n = 1, 10' of arc for n=2, 0.5 for n = 3  *)






FindFit[decs, c[1]*Cos[d[1] - 2*Pi/365.2427/24*x], {c[1], d[1]}, x]


temp0734 = Rationalize[ReadList["/mnt/villa/user/20180205/solar.txt",
"Number", "RecordLists" -> True], 0];

dates = Select[temp0734, #[[2]] <= 2466154 &];

ras = Transpose[dates][[3]];
decs = Transpose[dates][[4]];

diffra0 = Differences[ras];

diffras = Table[If[i < -Pi, i+2*Pi, i], {i, diffra0}];

ListPlot[superleft[diffras, 2], PlotRange -> All]

ListPlot[superleft[decs, 2], PlotRange -> All]

(* about 5*10^-6 radians for ra, 6/1000 radian for dec *)

rad0[t_] = superfour[diffras,2][t]

ra0[t_] = Mod[Chop[Integrate[rad0[t], t]], 2*Pi]

temp0752 = Table[ras[[i]] - ra0[i], {i, 1, Length[ras]}];

temp0753 = Table[If[i < 0, i+2*Pi, i], {i, temp0752}];
temp0754 = Mean[temp0753]

ra1[t_] = Mod[Chop[Integrate[rad0[t], t]] + 4.895320853488509, 2*Pi]

ra1[t_] = Chop[Integrate[rad0[t], t]] + 4.895320853488509

temp0755 = Table[ras[[i]] - ra1[i], {i, 1, Length[ras]}];

(* ra1 is within 2/1000 radian = 0.11 degree *)

(* t is in julian hours - 1 from epoch *)

FindRoot[ra1[t] == Pi, {t, 2400}]

(* 6366.03 is result *)

N[Take[ras, {6365, 6367}]-Pi]

(* very close to true equinox *)

(* convert unix time to position in array *)

unix2pos[t_] = (t-946728000+3600)/3600

N[unix2pos[1553609788]]

168579, so 

N[temp0734[[168579]]] // FullForm

FromJulianDate[2.458569083333*10^6]

is correct to nearest hour

ra[t_] = FullSimplify[ra1[unix2pos[t]], t>0]

dec0[t_] = superfour[decs, 2][t]

dec[t_] = FullSimplify[dec0[unix2pos[t]], t>0]

(* tests on 27 Mar 2019 *)

(* t = 1553697010 *)

abqsun[t_] = raDecLatLonGMST2azAlt[ra[t], dec[t], 35.05*Degree, -106.5*Degree,
unixtime2GMST[t]];

abqel[t_] = abqsun[t][[2]]

Plot[abqsun[t][[2]], {t, 1553666400, 1553666400+86400}]

FindRoot[abqsun[t][[2]] == -50/60*Degree, {t, 1553666400, 1553666400+86400}]

Round[1.5556768699307582*10^9]

brent[abqel, 1553666400, 1553666400+43200]

Clear[t]

FindRoot[raDecLatLonGMST2azAlt[ra[t], dec[t], 35.05*Degree, -106.5*Degree, 
unixtime2GMST[t]], {t, 1553697010}]












(*

2.4661545 or 2466154 rounded



In[16]:= FromJulianDate[temp0734[[1,2]]]                                        

Out[16]= DateObject[{2000, 1, 1, 12, 0, 0.}, Instant, Gregorian, 0.]

In[17]:= FromJulianDate[temp0734[[-1,2]]]                                       

Out[17]= DateObject[{2099, 12, 31, 18, 0, 0.}, Instant, Gregorian, 0.]

*)

(* max bad dec = 5500 is pretty bad elt wise *)

N[decs[[5500]]]/Degree is 13.1901 deg

2451774 = jd

FromJulianDate[2451774]

so aug 17th ish of 2000

jaklat = -6.18*Degree
jaklon = 106.83*Degree

jakartaalt[t_] = raDecLatLonGMST2azAlt[ra[t], dec[t], jaklat, jaklon, 
unixtime2GMST[t]][[2]]













(* end work 26 Mar 2019 *)

using mathematica directly for elevation at 0,0 location

AstronomicalData["Sun", "Azimuth"]

In[4]:= StarData["Sun", "TransitTime"]


StarData["Sun", "TransitTime", {Date -> {2014, 5, 1}}]

StarData["Sun", EntityProperty["Star", "TransitTime", 
 {"Date" -> {1970,1,1}, "Location" -> GeoPosition[{0,0}]}]]

(* above works *)

(* d = days from 2000/1/1 noon UTC *)

solarTransit[d_] := StarData["Sun", EntityProperty["Star", "TransitTime",
 {"Date" -> ToDate[3155716800 + 86400*d], "Location" -> GeoPosition[{0,0}]
 }]]





StarData["Sun", EntityProperty["Star", "TransitTime", 
 {"Date" -> {1970,1,1}], "Location" -> GeoPosition[{0,0}]]




Uses the output of:

bc-equator-dump-2 10 399 1999 2037

(and filter to 2000-2036)

to find an approx formula for solar right ascension and declination
using equitorial coordinates of date

*)

data = Import["/home/barrycarter/20180708/sun-ra-dec.txt", "Data"];

data2 = Select[data, #[[2]] >= JulianDate[{2000,1,1}] &&
 #[[2]] < JulianDate[{2037,1,1}] &];



decs = Transpose[data][[4]];

f1054[x_] = superfour[decs, 1][x]

t1122 = Table[{n, Max[Abs[superleft[decs,n]]]/Degree}, {n,1,10}]

3 or 6 or 8

int[x_] = Interpolation[decs][x]

Plot[{int[x], f1054[x]}, {x, 1, Length[decs]}]

Plot[{int[x]-f1054[x]}, {x, 1, Length[decs]}]






multiplier = 6.282467709670964




(* TODO: Differences is a builtin now *)

ras = Transpose[data][[3]];

radiffs = Mod[Differences[Transpose[data][[3]]], 2*Pi]

superfour[radiffs, 4]


ListPlot[difference[Transpose[data][[3]]]]

ListPlot[difference[Take[Transpose[data][[3]], 10000]]]

superfour[difference[Transpose[data][[3]]], 2]

superleft[difference[Transpose[data][[3]]], 2]




In[24]:= FromJulianDate[data[[1,2]]]

Out[24]= DateObject[{2000, 1, 1, 12, 0, 0.}, Instant, Gregorian, 0.]









