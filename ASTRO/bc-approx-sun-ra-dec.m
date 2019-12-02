(*

<writeup>

On "average", the Sun transits at local mean solar noon, which occurs at $(\left(\frac{\text{lon}}{15}+12\right) \bmod 24)$ UTC as measured in hours, where $\text{lon}$ is your longitude expressed in degrees, with western longitudes given as negative numbers.

We can get much better precision by adjusting this number using the [Equation of Time](https://en.wikipedia.org/wiki/Equation_of_time)




</writeup>

<reference>

regenerator.min.js is 979790b amd leaflet.js is 129192 so in that range

</reference>

*)

<formulas>

(*

Given an interpolation, return first and last point, interval length,
number of intervals, and coefficicents for each interval, where value
runs from 0 to 1 [not -1 to 1]; interpolation is assumed to have equal
length segments except possibly last segment;

THE RESULTS OF THE ARRAY ARE ROUNDED AND MULTIPLIED THIS IS NOT A
GENERAL FUNCTION

*)

intData[intpl_] := Module[{intLen, order, pts, t0}, 
 pts = intpl[[3,1]];
 order = intpl[[2,5,1]]-1;
 intLen = intpl[[3,1,2]] - intpl[[3,1,1]];
 t0 = Round[10^6*Table[CoefficientList[
  Chop[Normal[Series[intpl[pt + x*intLen], {x, 0, order}]]], x],
 {pt, pts}]];
 Return[{pts[[1]], pts[[-1]], intLen, Length[pts], order, t0}];
];

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {1600, 900}]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]

(* every nth element of a list, but always include first and last
elements; list must in {xi, yi} form, not just a list of values *)

(*

everyNth[list_, n_] := everyNth[list, n] = DeleteDuplicates[ 
 Join[list[[;;;;n]], {{1, list[[1,2]]}}, {{Length[list], list[[-1,2]]}}]];

*)

everyNth[list_, n_] := everyNth[list, n] = DeleteDuplicates[
 Join[list[[;;;;n]], {{list[[-1,1]], list[[-1,2]]}}]];

(* the alternate function does NOT include the last element *)

everyNthAlter[list_, n_] := everyNthAlter[list, n] = list[[;;;;n]];

(* create an interpolation function of order order for every nth
element of list, as defined above *)

interNth[list_, n_, order_:3] := interNth[list, n, order] = 
 Interpolation[everyNth[list,n], InterpolationOrder -> order]

interNthAlter[list_, n_, order_:3] := interNthAlter[list, n, order] = 
 Interpolation[everyNthAlter[list,n], InterpolationOrder -> order]

(* the differences between the original list and the interpolation
derived from taking every nth element at order order *)

diffNth[list_, n_, order_:3] := diffNth[list, n, order] = 
 Table[{list[[i,1]], list[[i,2]] - interNth[list, n, order][list[[i,1]]]}, {i, 1, Length[list]}]

diffNthAlter[list_, n_, order_:3] := diffNthAlter[list, n, order] = 
 Table[{list[[i,1]], list[[i,2]] - interNthAlter[list, n, order][list[[i,1]]]}, {i, 1, Length[list]}]

(* the absolute maximum difference between the original list and the
interpolation derived from taking every nth element at order order *)

maxDiffNth[list_, n_, order_:3] := maxDiffNth[list, n, order] = 
 Max[Abs[Transpose[diffNth[list, n, order]][[2]]]]

maxDiffNthAlter[list_, n_, order_:3] := maxDiffNthAlter[list, n, order] = 
 Max[Abs[Transpose[diffNthAlter[list, n, order]][[2]]]]

continify[list_] := Module[{d},
 d = Flatten[{0, Mod[Differences[list], 2*Pi]}];
 Return[list[[1]] + Accumulate[d]];
];

</formulas>

(* the moon will be worse, 2015-2024 *)

data =
ReadList["/mnt/villa/user/20191130/ASTRO/somemoon.txt",
"Number", "RecordLists" -> True];

decs = Table[{i[[4]], i[[6]]}, {i, data}];

maxDiffNth[decs, 24*60, 4]

(* 7.41 arcsecons *)

maxDiffNth[decs, 18*60, 4]

(* 2 arc seconds *)



(* doing 2015-2024 for now and may actually finalize as that *)

(* and since superleft doesn't help, lets do it again the right way *)

data =
ReadList["/mnt/villa/user/20191130/ASTRO/somesun.txt",
"Number", "RecordLists" -> True];

decs = Table[{i[[4]], i[[6]]}, {i, data}];

t1212 = interNth[decs, 24*60*9, 4];

intData[t1212]

(* output above is small enough to easily be a JS lib *)

ras = Table[{i[[4]], i[[5]]}, {i, data}];

ListPlot[ras, PlotRange->All]
showit2

t1219 = continify[Transpose[data][[5]]];

ListPlot[t1219, PlotRange->All]
showit2

t1223 = Transpose[{Transpose[data][[4]], t1219}];

maxDiffNth[t1223, 24*60*9, 4]

(* above is 3 seconds of arc *)

maxDiffNth[t1223, 24*60*7, 4]

(* above is 1.24146 seconds of arc which is acceptable *)






maxDiffNth[decs, 24*60*9, 4]

(* this is 4.33474 arcseconds hmmm-- because the last term is off? *)

maxDiffNthAlter[decs, 24*60*9, 4]

(* ok, after fix, the real one is 1.16598 seconds, and alter is ... 4.33 arcseconds??? *)

(* but... what if we ignore the last interpolation which is extrapolation *)

diffNthAlter[decs, 24*60*9, 4]

Max[Abs[Transpose[diffNthAlter[decs, 24*60*9, 4]][[2]]]]

0.0000210154

but if we drop the last elts of diff?

t1209 = Drop[diffNthAlter[decs, 24*60*9, 4], -24*60*9];

Max[Abs[Transpose[t1209][[2]]]]

1.16598 arcsec, so no help there




(* because superleft doesn't take double lists... *)

data =
ReadList["/mnt/villa/user/20191130/ASTRO/somesun.txt",
"Number", "RecordLists" -> True];

decs = Transpose[data][[6]];

decs2 = Table[{i, decs[[i]]}, {i, 1, Length[decs]}];

maxDiffNth[decs2, 24*60*9, 4]

t1142 = interNth[decs2, 24*60*9, 4];

(* above is 5.65283*10^-6 or 1.16598 arcseconds *)

t1113 = superleft[decs, 1];

ListPlot[t1113, PlotRange -> All];

t1114 = Table[{i, t1113[[i]]}, {i, 1, Length[t1113]}];

maxDiffNth[t1114, 24*60*9, 4]

(* above is 6.04046*10^-6 or 1.24593 arcseconds, hmmm *)

t1134 = superleft[decs, 2];

ListPlot[t1134, PlotRange -> All];
showit2

t1135 = Table[{i, t1134[[i]]}, {i, 1, Length[t1134]}];

maxDiffNth[t1135, 24*60*9, 4]

(* above is 6.05541*10^-6, slightly worse *)

(* note 1 arcsecond = 4.84814 microradians *)

(* answer is 0.0000210154 which is 4.33474s of arc *)

t1113 = superleft[decs, 1];

(* decs = Table[{i[[4]], i[[6]]}, {i, data}]; *)

(* finding error in something above, argh I changed it to use list with single elements, not lists of 2 elements *)

t1102 = everyNth[decs, 24*60*9];



t1059 = maxDiffNth[decs, 24*60*9, 4];




(* question on 2 Dec 2019: does removing linear/sin term help a lot *)

data =
ReadList["/mnt/villa/user/20191130/ASTRO/allsun.txt",
"Number", "RecordLists" -> True];

(* about 21M records above *)

(* decs = Transpose[data][[6]]; * )

decs = Table[{i[[4]], i[[6]]}, {i, data}];

maxDiffNth[decs, 24*60*9, 4]



(* not happy with how ;;;; behaves -- it turns out I am after all *)

Table[i, {i, 1, 100}][[;;;;7]]

(* oh, that always includes first element, hmmm *)

(* look at interpolation *)

i1755 = interNth[ras2, 60*7*24, 4];

(* first element and interval *)

i1755[[3,1,1]]

i1755[[3,1,2]] - i1755[[3,1,1]]

Series[i1755[x+i1755[[3,1,1]]], {x, 0, 5}]

s = "{firstPt: 123, lastPt: 456, intLen: 789, numPts: 1000, order: 4}";

intData[interNth[ras2, 60*7*24, 4]]

(* before going further lets test it *)

373315 = random element

ras2[[373315]] // InputForm

1.600235690817571*^9

x1831 = intData[interNth[ras2, 60*7*24, 4]];

(* lets try to JS print ths mother *)

jsify[out_] := 
 StringForm["{firstPt: ``, lastPt: ``, intLen: ``, nInts: ``, order: ``}",
 ToString[Round[out[[1]]]],
 Round[out[[2]][, Round[out[[3]]], out[[4]], out[[5]]];

1 + (1.600235690817571*^9 - x1831[[1]])/x1831[[3]]

38.0351 so 38th poly at .0351

x1831[[5,38]] get 9.32598

worked!

(* someting still lookks wrong *)

rand1844 = Table[{i, Random[]}, {i, 1, 10}];
int1845 = Interpolation[rand1844];

intData[int1845]

i1755[[1]]

(* on 30 Nov 2019, year by year since we'll prob need that for moon anyway? *)

data =
ReadList["/mnt/villa/user/20191130/ASTRO/sun-2020-per-minute.txt",
"Number", "RecordLists" -> True];

ras = continify[Transpose[data][[5]]];

ras2 = Table[{data[[i,4]], ras[[i]]}, {i, 1, Length[ras]}];

maxDiffNth[ras2, 60*24*30, 4]/Degree*3600

(* 241s above is too much! *)

maxDiffNth[ras2, 60*24*20, 4]/Degree*3600

(* above is 24s *)

maxDiffNth[ras2, 60*24*18, 4]/Degree*3600

(* 18s *)

maxDiffNth[ras2, 60*24*16, 4]/Degree*3600

(* 12s *)

maxDiffNth[ras2, 60*24*7, 4]/Degree*3600

decs = Table[{i[[4]], i[[6]]}, {i, data}];

maxDiffNth[decs, 128]/Degree*3600

maxDiffNth[decs, 65536]/Degree*3600

(above is 771 seconds, too much)

maxDiffNth[decs, 32768]/Degree*3600

(above is 58.5356 seconds, too much)

maxDiffNth[decs, 16384]/Degree*3600

(above is 6.39784 seconds, too much)

maxDiffNth[decs, 8192]/Degree*3600

(above is 0.533645 seconds, fine)

t1330 = Table[{i, maxDiffNth[decs, 2^i]/Degree*3600}, {i, 0, 20}]

ListLogPlot[t1330]

maxDiffNth[decs, 7*24*60]/Degree*3600

trying 4th

maxDiffNth[decs, 9*24*60, 4]/Degree*3600

maxDiffNth[decs, 32940, 4]/Degree*3600

(* above much too big at 64 seconds *)

maxDiffNth[decs, 32940/2, 4]/Degree*3600

(* still too big at 2.9 seconds *)

maxDiffNth[decs, 9*24*60, 4]/Degree*3600

(* lets go w/ 9 days *)

(* trying moon *)

data =
ReadList["/mnt/villa/user/20191130/ASTRO/moon-2020-per-minute.txt",
"Number", "RecordLists" -> True];

ra0 = Transpose[data][[5]];
ListPlot[ra0];
showit2

radiff = Mod[Differences[ra0], 2*Pi];

ra1 = Accumulate[radiff];

ListPlot[ra1, PlotRange -> All];
showit2

ra2 = ra0[[1]] + ra1

test1708 = continify[ra0];

maxDiffNth[test1708, 60*24, 4]




decs = Table[{i[[4]], i[[6]]}, {i, data}];

ras = Table[{i[[4]], i[[5]]}, {i, data}];

maxDiffNth[decs, 24*60*30]/Degree*3600

maxDiffNth[decs, 24*60*10]/Degree*3600

maxDiffNth[decs, 60*12]/Degree*3600                                    

1.31923

maxDiffNth[decs, 60*18, 4]/Degree*3600

1.18951

ListPlot[ras]

t1619 = Table[{0, Mod[-2*Pi/40320*i, 2*Pi]}, {i, 1, Length[ras]}];

ListPlot[Mod[ras+t1619,2*Pi]]

ListPlot[ras+t1619]
showit2

(* rectify list *)

(*
continify[list_] := Module[{ret, count},
 ret = {}; count = 0;
 For[i=1, i < Length[list], i++, 
  ret = Append[ret, list[[i]] + count*2*Pi];
  If[ Mod[list[[i]],Pi] > Mod[list[[i+1]],2*Pi], count++]
];
 Return[ret];
]

*)

t1647 = Table[Mod[i/10*Pi, 2*Pi], {i, 1, 1000}]

ListPlot[t1647, PlotJoined -> True]






t1643 = Table[i, {i,1,20}];

Print[continify[t1643]]



For[i=1, i<=10, i++, If[i<5, Print["less"]]; Print[i]];




























(* below also on 28 Nov 2019, splining attempt *)

data = Rationalize[ReadList["/mnt/villa/user/20180205/solar.txt",
"Number", "RecordLists" -> True], 0];

ras = Transpose[data][[3]];
decs = Transpose[data][[4]];

(* below is just numbered hours *)

decs2 = Table[{i, decs[[i]]}, {i, 1, Length[decs]}];

t1315 = Interpolation[decs2];

i1316 = interNth[decs2, 24*9, 4];

f1320[x_, i_] = x*24*9/2 + 24*9*(i+1/2);

Series[i1316[x/24/9*2 + 24*9*(5+1/2)], 

i1327 = Interpolation[decs[[;;;;24*9]], InterpolationOrder -> 4];

coeffize[p_] := Table[Coefficient[p, x, i], {i,0,4}]

N[Normal[Series[i1327[x/2+17+1/2], {x, 0, 5}]]]

N[Normal[Series[i1327[x/2+0+1/2], {x, 0, 5}]]]

t1337 = Table[coeffize[N[Normal[Series[i1327[x/2+i+1/2], {x, 0, 5}]]]],
 {i, 1, 4059}];

Round[t1337*10^6] >> /home/barrycarter/20191129/decsmrad.txt









(* below is Unix days *)

decs2 = Table[{i/24 + 10957+1/2 - 1/24, decs[[i]]}, {i, 1, Length[decs]}];

maxDiffNth[decs2, 24*9, 4]/Degree*3600.

Chop[N[Expand[Normal[Series[interNth[decs2, 24*9, 4][x], 
 {x, decs2[[24*9/2,1]], 5}]]]]]

Chop[N[Expand[Normal[Series[interNth[decs2, 24*9, 4][x], 
 {x, decs2[[24*9/2+24*9,1]], 5}]]]]]

(* might be easier with just plain numbers *)

decs2 = Table[{i, decs[[i]]}, {i, 1, Length[decs]}];

Chop[N[Expand[Normal[Series[interNth[decs2, 24*9, 4][x], 
 {x, 24*9/2, 5}]]]]]

int1 = Interpolation[decs2, InterpolationOrder -> 4];

int2 = Interpolation[decs2[[;;;;24*9]], InterpolationOrder -> 4];

Plot[(int1[x]-int2[x])/Degree*3600, {x, decs2[[1,1]], decs2[[-1,1]]},
PlotRange -> All]

Length[int2[[4]]]

(* above is 4059 meaning 4059 polynomials *)

Length[int2[[3,1]]] = the actual x values

Series[int2[x], {x, int2[[3,1,1]], 5}]

Table[Series[int2[x], {x, int2[[3,1,i]], 5}], {i, 1, 4059}];

Table[Normal[N[Series[int2[x], {x, int2[[3,1,i]], 5}]]], {i, 1, 4059}];

Table[Expand[Normal[N[Series[int2[x], {x, int2[[3,1,i]], 5}]]]], {i, 1, 4059}];

t2234 = Table[Chop[Expand[Normal[N[Series[int2[x], {x, int2[[3,1,i]], 5}]]]]], 
 {i, 1, 4059}];

(* given an interpolatio object... *)

f2239[int_] := Table[(int[[3,1,i]] + int[[3,1,i+1]])/2, 
 {i, 1, Length[int[[3,1]]]-1}]

Series[int2[x+46899], {x, 0, 5}]

Chop[N[Normal[Series[int2[x+46899], {x, 0, 5}] ]]]

Chop[N[Normal[Series[int2[(x/9*2+46899)], {x, 0, 5}]]]]

Chop[N[Normal[Series[int2[(x*9/2+46899)], {x, 0, 5}]]]]

(int2[[3,1,-1]]-int2[[3,1,1]])/(Length[int2[[3,1]]]-1)

Exponent[1 + x^2 + a x^3, x] = highest power

(* the polynomial associated with the nth interval of an
interpolation, where the interval is treated as [-1, 1] *)

polynomial[int_, n_] :=
 (int[[3,1,n]] + int[[3,1,n+1]])/2

int[[2,4,1]] = interp order




























(* decs2 = Table[{i, decs[[i]]}, {i, 1, Length[decs]}]; *)

maxDiffNth[decs2, 1]

maxDiffNth[decs2, 24]/Degree*3600.

maxDiffNth[decs2, 2^8]/Degree*3600.

maxDiffNth[decs2, 2^7]/Degree*3600.

maxDiffNth[decs2, 181]/Degree*3600.

maxDiffNth[decs2, 150]/Degree*3600.


maxDiffNth[decs2, 2^8, 4]/Degree*3600.

(* lets use 150 and 3 to get to the next point *)

interNth[decs2, 150]

Chop[N[Expand[Normal[Series[interNth[decs2, 150][x], {x, 75, 5}]]]]]

Chop[N[Expand[Normal[Series[interNth[decs2, 150][x], {x, 75+150*1, 5}]]]]]

Chop[N[Expand[Normal[Series[interNth[decs2, 150][x], {x, 75+150*10, 5}]]]]]

t1622 = Table[
 Chop[N[Expand[Normal[Series[interNth[decs2, 150][x], {x, 75+150*i, 5}]]]]],
 {i, 0, 5843}];

maxDiffNth[decs2, 1000, 6]/Degree*3600

maxDiffNth[decs2, 1000, 10]/Degree*3600

maxDiffNth[decs2, 200, 3]/Degree*3600.

maxDiffNth[decs2, 200, 4]/Degree*3600.

maxDiffNth[decs2, 256, 4]/Degree*3600.

maxDiffNth[decs2, 256, 5]/Degree*3600.

maxDiffNth[decs2, 256, 3]/Degree*3600.

(* 4th degree seems best *)

(* 24*9 hours = 1.01809 seconds error *)




















temp5 = decs2[[;;;;5]];

int1 = Interpolation[decs2];
int5 = Interpolation[temp5];

Plot[{int1[x], int5[x]}, {x, 1, Length[decs]}]

Plot[{int1[x]-int5[x]}, {x, 1, Length[decs]}, PlotRange->All]

int24 = Interpolation[decs2[[;;;;24]]];

Plot[{int1[x]-int24[x]}, {x, 1, Length[decs]}, PlotRange->All]

Clear[everyNth];
Clear[interNth];
Clear[diffNth];
Clear[maxDiffNth];

everyNth[list_, n_] := everyNth[list, n] = DeleteDuplicates[
 Join[list[[;;;;n]], {{1, list[[1,2]]}}, {{Length[list], list[[-1,2]]}}]];

interNth[list_, n_] := interNth[list, n] = Interpolation[everyNth[list,n]]

maxDiffNth[decs2, 1]

t1557 = Table[maxDiffNth[decs2, i]/Degree*3600, {i, 1, 10}]

t1558 = Table[{i, maxDiffNth[decs2, i]/Degree*3600}, {i, 1, 24*30, 24}]





(* test table *)

test1 = Table[{i, Sin[i/24]}, {i,1,10}];

Append[Append[test1[[;;;;2]], {1, test1[[1]]}], {Length[test1],
test1[[Length[test1]]]}]




{ {1, test1[[1]]}, test1[[;;;;7]], {Length[test1], test1[[Length[test1]]]} }














(* work below on 28 Nov 2019 - envelope functions *)

data = Rationalize[ReadList["/mnt/villa/user/20180205/solar.txt",
"Number", "RecordLists" -> True], 0];

loy = Rationalize[24*365.242190402,0]

decf = Interpolation[decs]

n = 1;

f[x_] = c[0] + e[1]*(x-Length[decs]/2)*Cos[h[1]-1*2*Pi/loy*x] + 
        Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x], {i,1,n}];

vars = Flatten[{e[1], h[1], c[0], Table[{c[i], d[i]}, {i,1,n}]}];

ff = FindFit[decs, f[x], vars, x];

g[x_] = N[f[x] /. ff];

Plot[{(g[x]-decf[x])/Degree*60*60}, {x, 1, Length[decs]}, PlotRange->All]

(* envelope *)

temp0854 = Table[decs[[i]]-g[i], {i,1,Length[decs]}];

Plot[1500+500*Cos[x*2*Pi/24/365], {x, 0, 24*365}]

temp0835[x_] = 1500+500*Cos[x*2*Pi/24/365]

Plot[{(g[x]-decf[x])/Degree*60*60/temp0835[x]}, {x, 1, 24*365}, 
 PlotRange->All]

temp0836[x_] = (1500+500*Cos[x*2*Pi/24/365])*Cos[2*Pi*x/365/12]

Plot[{(g[x]-decf[x])/Degree*60*60-temp0836[x]}, 
 {x, 1, Length[decs]}, PlotRange->All]

temp0847[x_] = c[0] + (c[1]*Cos[x*2*Pi/loy-c[2]]*Cos[2*Pi*x/loy*2-c[3]])

vars = {c[0], c[1], c[2], c[3]}

ff0852 = FindFit[temp0854, temp0847[x], vars, x]

temp0919[x_] = temp0847[x] /. ff0852

Plot[{g[x] - temp0919[x]}, {x, 1, Length[decs]}]

ff0906 = NonlinearModelFit[temp0854, temp0847[x], vars, x]

temp052[x_] = temp0847[x] /. ff0852

temp0910[x_] = c[0] + (c[1]*Cos[x*2*Pi/loy-c[2]]*Cos[2*Pi*x/loy*2-c[2]])

ff0910 = FindFit[temp0854, temp0910[x], vars, x]

temp0913[x_] = c[0] + c[1]*Cos[x*2*Pi/loy]*Cos[2*Pi*x/loy*2] + 
 c[2]*Sin[x*2*Pi/loy]*Sin[2*Pi*x/loy*2]

ff0915 = FindFit[temp0854, temp0913[x], vars, x]

(* generalizing concept of adding cosine products *)

temp0922[x_] = c[0] + a[1]*Cos[x*2*Pi/loy-p[1]] + 
 a[2]*Cos[x*2*Pi/loy-p[2]]*Cos[x*2*Pi/loy*2-p[3]]

vars = {c[0], a[1], a[2], p[1], p[2], p[3]}

ff0925 = FindFit[decs, temp0922[x], vars, x]

f0925[x_] = temp0922[x] /. ff0925

Plot[g[x]-f0925[x], {x,1,Length[decs]}]

(* lets try using residuals *)

(* first, basic cos with 1 yr pd *)

ff0931[x_] = c[0] + a[1]*Cos[2*Pi*x/loy - p[1]]

vars = {c[0], a[1], p[1]}

ff0932 = FindFit[decs, ff0931[x], vars, x]

f0933[x_] = ff0931[x] /. ff0932

res1 = Table[decs[[i]] - f0933[i], {i, 1, Length[decs]}];

(* now, approx res1 with cosine prodct *)

f0936[x_] = c[0] + (c[1]*Cos[x*2*Pi/loy-c[2]]*Cos[2*Pi*x/loy*2-c[3]])

vars = {c[0], c[1], c[2], c[3]}

ff0936 = FindFit[res1, f0936[x], vars, x]

f0937[x_] = f0936[x] /. ff0936

res2 = Table[res1[[i]] - f0937[i], {i, 1, Length[res1]}];

f0953[x_] = c[0] +(c[1]*Cos[x*2*Pi/loy-c[2]]+c[4])*(c[5]Cos[2*Pi*x/loy*2-c[3]])

f0953[x_] = c[0] + (c[4] + Cos[x*2*Pi/loy-c[2]]) * Cos[2*Pi*x/loy*2-c[3]]

f0953[x_] = c[0] + (c[4] + c[1]*Cos[x*2*Pi/loy-c[2]]) * Cos[2*Pi*x/loy*2-c[3]]

vars = {c[0], c[1], c[2], c[3], c[4]}

ff0953 = FindFit[res1, f0953[x], vars, x]

f0954[x_] = f0953[x] /. ff0953

t1118 = Table[f0954[i], {i, 1, Length[res1]}];

ListPlot[{res1, t1118}]

res2 = Table[res1[[i]] - f0954[i], {i, 1, Length[res1]}];

res3 = Table[res1[[i]] - f0954[i]/2, {i, 1, Length[res1]}];

ListPlot[res2]
showit2
































(* work below on 27 Nov 2019 *)

(* data = Rationalize[ReadList["/mnt/villa/user/20191127/sun-2020-per-minute.txt", 
"Number", "RecordLists" -> True], 0]; *)

data = Rationalize[ReadList["/mnt/villa/user/20191127/year-2020.txt",
"Number", "RecordLists" -> True], 0];

ras = Transpose[data][[4]];
decs = Transpose[data][[5]];

raSlope = (ras[[-1]] - ras[[1]])/(Length[ras]-1)

ras2 = Table[ras[[i]] - (i-1)*raSlope, {i, 1, Length[ras]}];



loy = Rationalize[24*60*365.242190402,0]

decf = Interpolation[decs]

(* reusing variable as test *)

decf = Interpolation[ras2];

n = 5;

f[x_] = c[0] + e[1]*(x-Length[decs]/2)*Cos[h[1]-1*2*Pi/loy*x] + 
        Sum[c[i]*Cos[d[i] - i*2*Pi/loy*x], {i,1,n}];

vars = Flatten[{e[1], h[1], c[0], Table[{c[i], d[i]}, {i,1,n}]}];

ff = FindFit[decs, f[x], vars, x];

g[x_] = N[f[x] /. ff];

Plot[{(g[x]-decf[x])/Degree*60*60}, {x, 1, Length[decs]}, PlotRange->All]

(*

n=1 about 1500 seconds, 500 seconds except for end

n=2 about 1100 seconds, 500 seconds except for end

n=3 about 75 seconds, 30 seconds except for end

n=4 about 25 seconds, 12 seconds except for end

n=5 about 4 seconds consistently

n=7 about 3 seconds consistently

*)

diffras = Table[If[i < -Pi, i+2*Pi, i], {i, diffra0}];

(* below is in arcseconds *)

ListPlot[superleft[decs, 1]/Degree*3600, PlotRange -> All]

ListPlot[superleft[decs, 2]/Degree*3600, PlotRange -> All]

(* above takes forever *)

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






