(*

<writeup>

On "average", the Sun transits at local mean solar noon, which occurs at $(\left(\frac{\text{lon}}{15}+12\right) \bmod 24)$ UTC as measured in hours, where $\text{lon}$ is your longitude expressed in degrees, with western longitudes given as negative numbers.

We can get much better precision by adjusting this number using the [Equation of Time](https://en.wikipedia.org/wiki/Equation_of_time)




</writeup>

*)

<formulas>

</formulas>

(* work below 26 Mar 2019 *)

(* math2 bc-astro-formulas.m *)

(* TODO: make length of year more accurate *)

loy = 24*365.2425;

(* from http://hpiers.obspm.fr/eop-pc/models/constants.html *)

loy = 24*365.242190402;

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

(* above = w/in 30' of arc for n = 1, 10' of arc for n=2, 0.5 for n = 3, n=10 still gives 0.4 minutes  *)






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

(* new work below 31 Mar 2019 *)

data = ReadList["/mnt/villa/user/20190331/sun-2000-2039.txt", "Number",
"RecordLists" -> True];

(* from 2000-01-01 noon to 2099-12-31 noon *)

FromJulianDate[data[[1,2]]]
FromJulianDate[data[[-1,2]]]

(* ugly data cleaning *)
data = Drop[data, -41];


(* now 1999-12-31 noon to 2039-12-31 noon *)

decs = Transpose[data][[4]];

loy = 365.242190402*24;

decf = Interpolation[decs];

temp0835 = Table[{i/Length[decs], decs[[i]]}, {i,1, Length[decs]}];
xp = Table[x^i, {i,0,99}];
temp0836[x_] = Fit[temp0835, xp, x]
temp0837[x_] = Interpolation[temp0835][x]
Plot[temp0837[x] - temp0836[x], {x,0,1}]


(* n = 4, 36 arcseconds so using it *)

n = 4;

f[x_] = c[0] + e[1]*(x)*Cos[h[1]-1*2*Pi/loy*x] + 
        Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x], {i,1,n}];

vars = Flatten[{e[1], h[1], c[0], Table[{c[i], d[i]}, {i,1,n}]}];

ff = FindFit[decs, f[x], vars, x];

f0827 = Fit[decs, xp, x];

f0828[x_] = N[f0827]

Plot[{(f0828[x]-decf[x])/Degree*60}, {x, 1, Length[decs]}, PlotRange->All]

g[x_] = N[f[x] /. ff];

Plot[{(g[x]-decf[x])/Degree*60}, {x, 1, Length[decs]}, PlotRange->All]

g[x_] = 

0.006600347081705735 - 0.4060412089312136*
  Cos[24.96802053223509 - 0.0007167829858620732*x] + 
 3.389951327804244*^-10*x*Cos[0.13820827714442324 + 0.0007167829858620732*x] - 
 0.006650306895424216*Cos[0.0879921938557077 + 0.0014335659717241464*x] + 
 0.002988449799865202*Cos[3.6167056463110376 + 0.0021503489575862194*x] + 
 0.0001423856004896973*Cos[3.547006960283199 + 0.0028671319434482928*x]

(* checking vs random times, not hourly *)

testdata = ReadList["/tmp/randcheck.txt", "Number", "RecordLists" -> True]; 

change[d_] = 24*d-5.8837056`*^7+1

testtab = Table[g[change[i[[2]]]] - i[[4]], {i, testdata}];

Max[Abs[testtab]]

(* 0.000143475 = 30 arc seconds, 32 arcsecs a bit out *)

jd2unix[d_] = (d-2451545.0)*86400 + 946728000

unix2jd[t_] = (t-946728000)/86400 + 2451545

h[t_] = Expand[Simplify[N[g[change[unix2jd[t]]]]]]



h[t_] = Chop[Simplify[g[change[unix2jd[t]]], t>0]]

(* work below 6 Apr 2019 *)

data = ReadList["/mnt/villa/user/20190331/sun-2000-2039.txt", "Number",
"RecordLists" -> True];

(* ugly data cleaning *)
data = Drop[data, -41];

(* from 2000-01-01 noon to 2099-12-31 noon *)

FromJulianDate[data[[1,2]]]
FromJulianDate[data[[-1,2]]]

(* now 1999-12-31 noon to 2039-12-31 noon *)

ras = Transpose[data][[3]];

rasf = Interpolation[ras];

radiffs = Mod[Differences[Transpose[data][[3]]], 2*Pi];

radifff = Interpolation[radiffs]

loy = 365.242190402*24;

n = 4;

f[x_] = c[0] + e[1]*(x)*Cos[h[1]-1*2*Pi/loy*x] + 
        Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x], {i,1,n}];

vars = Flatten[{e[1], h[1], c[0], Table[{c[i], d[i]}, {i,1,n}]}];

ff = FindFit[radiffs, f[x], vars, x];

g[x_] = N[f[x] /. ff];

j[x_] = Integrate[g[x], x]

Plot[Mod[rasf[x]-j[x],2*Pi],{x,1,Length[ras]}, PlotRange -> All]

t1854 = Table[Mod[ras[[i]] - j[i], 2*Pi], {i, 1, Length[ras]}];

4.877075022487457 = const of int

Plot[{(g[x]-radifff[x])/Degree*60}, {x, 1, Length[radiffs]}, PlotRange->All]

(* work below 7 Apr 2019 for reduced latitude to geodetic latitude *)

a[x_] = GeodesyData["WGS84", {"ReducedLatitude", x}]

b[x_] = InverseFunction[a][x]

(* tests *)

data = ReadList["/mnt/villa/user/20190331/sun-2000-2039.txt", "Number",
"RecordLists" -> True];


t1037 = jd2unixtime[data[[4,2]]]

approxSolarDec[t1037]


(* ugh, fixing functions to use some reasonable time thing *)

unixtime2index[d_] = d/3600-262979+24

unixtime2index[946641600]
unixtime2index[2208942000]

unixdate2index[d_] = unixtime2index[d*86400]

FullSimplify[approxSolarDec[unixdate2index[d]], d>0]

(* tests *)

check[lat_, lon_, t_, res_] =
 raDecLatLonGMST2Alt[approxSolarRA[t/86400], approxSolarDec[t/86400], 
  lat, lon, gmst[t/86400]] - res


(* same process w/ a slightly more accurate output *)

data = Drop[ReadList["/mnt/villa/user/20190407/unixt.txt", "Number",
"RecordLists" -> True], -41];

(* above is 1999-12-31T06:36:00+0000 to 2039-12-31T05:36:00+0000 *)

ras = Transpose[data][[4]];

rasf = Interpolation[ras];

radiffs = Mod[Differences[ras], 2*Pi];

radifff = Interpolation[radiffs]

loy = 365.242190402*24;

(* 

n=1 yields 2.29183 degree accuracy
n=2 yields 6.87549 minutes accuracy
n=3 yields 3.43775 minutes accuracy
n=4 yields 52 seconds accuracy
n=5 yields 41 seconds accuracy
n=6 doesn't help
n=10 doesn't help

*)

n = 5;

f[x_] = c[0] + e[1]*(x)*Cos[h[1]-1*2*Pi/loy*x] + 
        Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x], {i,1,n}];

vars = Flatten[{e[1], h[1], c[0], Table[{c[i], d[i]}, {i,1,n}]}];

ff = FindFit[radiffs, f[x], vars, x];

g[x_] = N[f[x] /. ff];

j[x_] = Integrate[g[x], x]

(*
ListPlot[Table[Mod[ras[[i]] - j[i], 2*Pi], {i, 1, Length[ras]}] , 
 PlotRange -> All]
*)

constInt = Mean[Table[Mod[ras[[i]] - j[i], 2*Pi], {i, 1, Length[ras]}]]

k[x_] = j[x] + constInt

(* the 'j' below because the constInt flips at 0 *)

Plot[Mod[rasf[x]-j[x],2*Pi],{x,1,Length[ras]}, PlotRange -> All]

unix2pos[t_] = (t-946622160+3600)/3600

unixday2pos[d_] = unix2pos[d*86400]

(* work below 8 Jun 2019 *)

t0909 = Rationalize[ReadList["/mnt/villa/user/20180205/solar.txt",
"Number", "RecordLists" -> True], 0];

dates = Select[t0909, #[[2]] <= 2466154 &];

ras = Transpose[dates][[3]];
decs = Transpose[dates][[4]];

diffra0 = Differences[ras];
diffras = Table[If[i < -Pi, i+2*Pi, i], {i, diffra0}];

fdec = FindFormula[decs, x]
fras = FindFormula[diffras, x]

(* both above are constant! *)

fdec2 = FindFormula[decs-fdec, x];

fdec3 = FindFormula[10000*(decs-fdec), x];

(* below on 9 Jun 2019, I may actually need two coords for Predict *)

t0909 = Rationalize[ReadList["/mnt/villa/user/20180205/solar.txt",
"Number", "RecordLists" -> True], 0];

dates = Select[t0909, #[[2]] <= 2466154 &];

decs = Table[i[[2]] -> i[[4]], {i, dates}];

pdec = Predict[decs];

decs2 = Table[{i[[2]], i[[4]]}, {i, dates}];

fdecs = FindFormula[decs2];

(* above gives 0 and thus fails miserably)






