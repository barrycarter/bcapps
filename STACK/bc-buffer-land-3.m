(*

this is the DIY version using coastline data

*)

<formulas>

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

</formulas>

t1928 = Import["/home/user/20180806/coastline/GSHHS_shp/c/GSHHS_c_L1.shp",
 "Data"];

RegionQ[t1928[[1,2,2,1]]]

(above is true!, but it's planar)





polys = Table[t1928[[1,2,2,i,1]], {i, 1, Length[t1928[[1,2,2]]]}];

t2008[elts_] := Table[
 GeoDistance[Reverse[elts[[i]]], Reverse[elts[[i+1]]]],
{i, 1, Length[elts]-1}];




Graphics[t1928[[1,2,2]]]

(* below is just 1 poly *)

Graphics[t1928[[1,2,2,1]]]


Short[t1928[[1,2,2]],10]

179837 polys

Graphics[Apply[Line,t1928[[1,2,2]], {1}]]

Graphics[Point[Flatten[Apply[List,t1928[[1,2,2]], {1}], 2]]]

t1953 = Table[RandomReal[{-1,1}, 3], {i, 1, 10^7}];

t1954 = Table[i/Norm[i], {i, t1953}];

testpt0 = RandomReal[{-1,1}, 3]

testpt = testpt0/Norm[testpt0];

Table[testpt.i, {i,t1954}];

about 1.2s with 10M pts

562d for fine mesh plot


min dist point to line, assuming line endpts are on sphere

line[t_] = {a + t*(d-a), b + t*(e-b), c+ t*(f-c)};

conds = Element[{a,b,c,d,e,f,x,y,z,t}, Reals]

dist[x_,y_,z_] = Simplify[{x,y,z}.line[t]/Norm[line[t]],conds]

D[dist[x,y,z], t]

sol = Solve[D[dist[x,y,z], t] ==0, t]

pointLineDist[a_,b_,c_,d_,e_,f_,x_,y_,z_] := Module[{t},
 t = (b^2*d*x + c^2*d*x - a*b*e*x - a*c*f*x - a*b*d*y + a^2*e*y + c^2*e*y - 
  b*c*f*y - a*c*d*z - b*c*e*z + a^2*f*z + b^2*f*z)/
 (b^2*d*x + c^2*d*x - a*b*e*x - b*d*e*x + a*e^2*x - a*c*f*x - c*d*f*x + 
  a*f^2*x - a*b*d*y + b*d^2*y + a^2*e*y + c^2*e*y - a*d*e*y - b*c*f*y - 
  c*e*f*y + b*f^2*y - a*c*d*z + c*d^2*z - b*c*e*z + c*e^2*z + a^2*f*z + 
  b^2*f*z - a*d*f*z - b*e*f*z);
 t = Min[Max[t,0], 1];
 Return[((a - a*t + d*t)*x + (b - b*t + e*t)*y + (c - c*t + f*t)*z)/
 Sqrt[(a - a*t + d*t)^2 + (b - b*t + e*t)^2 + (c - c*t + f*t)^2]];
];

Timing[Table[Apply[pointLineDist, RandomReal[{-1,1}, 9]], {i,1,10^6}]];

(about 41.48s)

7282 lines (about 1/3s per point)

141 days

line[t].{x,y,z}

t2153 = Solve[({x,y,z}-line[t]).{-a + d, -b + e, -c + f} == 0, t];

t2153[[1,1,2]] /. {
 z^2 -> 1-x^2-y^2,
 c^2 -> 1-a^2-b^2,
 f^2 -> 1-d^2-e^2}


t2157 = Solve[({x,y,z}-line[t]/Norm[line[t]]).
 {-a + d, -b + e, -c + f} == 0, t];





 









solt2[a_,b_,c_,d_,e_,f_,x_,y_,z_] = sol[[1,1,2]];

solt[a_,b_,c_,d_,e_,f_,x_,y_,z_] = FullSimplify[sol[[1,1,2]] /. {c^2
-> 1-a^2-b^2, f^2 -> 1-e^2-d^2, z^2 -> 1-x^2-y^2}, conds];

Timing[Table[Apply[solt, RandomReal[{-1,1}, 9]], {i, 1000000}]]

for 1M points this takes 15.4404s

Timing[Table[Apply[solt2, RandomReal[{-1,1}, 9]], {i, 1000000}]]

only takes 2.41914 (Wrong, it takes 25+s)

solt3 = Compile[{a,b,c,d,e,f,x,y,z}, solt2[a,b,c,d,e,f,x,y,z]];

Timing[Table[Apply[solt3, RandomReal[{-1,1}, 9]], {i, 1000000}]];

26.6 seconds so not shorter

solt4 = Compile[{a,b,c,d,e,f,x,y,z}, solt[a,b,c,d,e,f,x,y,z]];

Timing[Table[Apply[solt4, RandomReal[{-1,1}, 9]], {i, 1000000}]];

16.+ s




7282 lines (rough) in the polys

7282*9000*4500/10^6*2.41/86400 = 8 days ouch

dist[x,y,z] /. t -> sol[[1,1,2]]

(below is wrong, doesn't compensate for length )

nmin[a_, b_, c_, d_, e_, f_, x_, y_ ,z_] :=
 NMaximize[{{a + t*(d-a), b + t*(e-b), c+ t*(f-c)}.{x,y,z}, {t>=0, t<=1}}, t]

Timing[Table[Apply[nmin, RandomReal[{-1,1}, 9]], {i, 1, 10000}]];

19.92 sec for just 10K ick


Minimize[{{a + t*(d-a), b + t*(e-b), c+ t*(f-c)}.{x,y,z}, 
 {t>=0, t<=1, x^2 + y^2 + z^2 == 1}}, t, 
 Reals]

Minimize[{Norm[{a + t*(d-a), b + t*(e-b), c+ t*(f-c)}-{x,y,z}],
 {t>=0, t<=1}}, t, 
 Reals]
 
t2122 = Solve[{
 D[dist[x,y,z]^2, t] == 0,
 x^2 + y^2 + z^2 == 1,
 a^2 + b^2 + c^2 == 1,
 d^2 + e^2 + f^2 == 1}, t, Reals]

Simplify[dist[x,y,z]^2, {
 x^2 + y^2 + z^2 == 1,
 a^2 + b^2 + c^2 == 1,
 d^2 + e^2 + f^2 == 1
}];


u = sph2xyz[th1, ph1, 1];
v = sph2xyz[th2, ph2, 1];

w = Cross[Cross[u,v], u]

pos[t_] = u*Cos[t] + w*Sin[t]


given sph coords fine dist from th3,th3 to line from ph1,th1 to ph2,th2

conds = {-Pi < th1 < Pi, -Pi/2 < ph1 < Pi/2, 
         -Pi < th2 < Pi, -Pi/2 < ph2 < Pi/2, 
         -Pi < th3 < Pi, -Pi/2 < ph3 < Pi/2, 
         0 < t < 1};

line[t_] = sph2xyz[th1, ph1, 1] +  
 t*(sph2xyz[th2, ph2, 1] - sph2xyz[th1, ph1, 1]);

dp[t_] = Simplify[sph2xyz[th3, ph3, 1].line[t]/Norm[line[t]], conds]

derv[t_] = Simplify[D[dp[t], t], conds]

sol0 = Simplify[Solve[D[dp[t], t] == 0, t], conds]

sol[th1_, ph1_, th2_, ph2_, th3_, ph3_] = 
 Simplify[Solve[Simplify[D[dp[t], t]] == 0, t][[1,1,2]],conds];

doinmg parsing derv[t] into its form helps... its a product

Head[derv[t]]

derv[t][[1]] has no sols

Solve[derv[t][[2]] == 0, t][[1,1,2]]

rand := Flatten[Table[
 {RandomReal[{-Pi, Pi}], RandomReal[{-Pi/2 ,Pi/2}]}, {i,3}]];

Timing[Table[Apply[sol, rand], {i,1,10000}]];

0.57339 for 10K applications

4.49868 for 100K applications

sol2 = Compile[{th1, ph1, th2, ph2, th3, ph3}, sol[th1, ph1, th2, ph2,
 th3, ph3]];

Timing[Table[Apply[sol2, rand], {i,1,100000}]];

4.68059 for 100K so not much faster

now lets fix first 4 params and gridify th3, ph3

Timing[
 Table[sol[0.0377192, -1.51973, 1.44943, -1.2608, lon*Degree, lat*Degree],
 {lon, -180, 180}, {lat, -90, 90}]];

5.02408 for the 64800 above

Timing[
 Table[sol2[0.0377192, -1.51973, 1.44943, -1.2608, lon*Degree, lat*Degree],
 {lon, -180, 180}, {lat, -90, 90}]];

2.16686 for the 64800 above

Timing[
 Table[sol2[0.0377192, -1.51973, 1.44943, -1.2608, lon*Degree, lat*Degree],
 {lon, -180, 180, 0.5}, {lat, -90, 90, 0.5}]];

7.59381 for the 259200 above

now lets memoize the trig functions

sol3[th1_, ph1_, th2_, ph2_, th3_, ph3_] = 
 sol[th1, ph1, th2, ph2, th3, ph3] /. {Sin[x_] -> sin[x], Cos[x_] -> cos[x]}

sin[x_] := sin[x] = Sin[x]
cos[x_] := cos[x] = Cos[x]

Timing[
 Table[sol3[0.0377192, -1.51973, 1.44943, -1.2608, lon*Degree, lat*Degree],
 {lon, -180, 180, 0.5}, {lat, -90, 90, 0.5}]];

9.10s first run

about the same second run (8.2s)

not really faster sigh

Series[sol[th1, ph1, th2, ph2, th3, ph3], {th3, 0, 2}]

ContourPlot[ sol3[0.0377192, -1.51973, 1.44943, -1.2608, lon*Degree,
lat*Degree], {lon, -180, 180}, {lat, -90, 90}, ColorFunction -> Hue,
ContourLabels -> True]

ContourPlot[GeoDistance[{45, 0}, {lat, lon}], {lon, -10, 10}, 
 {lat, 35, 55}, ColorFunction -> Hue, ContourLabels -> True]


sph2xyz[th1, ph1, 1].sph2xyz[th2, ph2, 1]

when simplified, this is (cosine of angle):

Cos[ph1] Cos[ph2] Cos[th1 - th2] + Sin[ph1] Sin[ph2]

Solve[Cos[ph1] Cos[ph2] Cos[dth] + Sin[ph1] Sin[ph2] == x, 
 dth, Reals]

Solve[{Cos[ph1] Cos[ph2] Cos[dth] + Sin[ph1] Sin[ph2] == x, conds}, 
 dth]

Solve[Cos[ph1] Cos[ph2] Cos[dth] + Sin[ph1] Sin[ph2] == x, 
 dth, Reals]

Simplify[Solve[Cos[ph1] Cos[ph2] Cos[dth] + Sin[ph1] Sin[ph2] == x, 
 dth, Reals], {conds, x>0, dth>0}]

Simplify[Solve[Cos[ph1] Cos[ph2] cdth + Sin[ph1] Sin[ph2] == x, 
 ddth, Reals], {conds, x>0, cdth>0}]

cdth -> Sec[ph1] Sec[ph2] (x - Sin[ph1] Sin[ph2]

(x-Sin[ph1]*Sin[ph2])/Cos[ph1]/Cos[ph2]

dth[d_, ph1_, ph2_] = (ArcCos[d]-Sin[ph1]*Sin[ph2])/Cos[ph1]/Cos[ph2]

ok something went wrong

ArcCos[sph2xyz[th1, ph1, 1].sph2xyz[th2, ph2, 1]]

ArcCos[Cos[ph1] Cos[ph2] Cos[th1 - th2] + Sin[ph1] Sin[ph2]]

ArcCos[Cos[ph1] Cos[ph2] Cos[dth] + Sin[ph1] Sin[ph2]] = d

Cos[ph1] Cos[ph2] Cos[dth] + Sin[ph1] Sin[ph2] = Cos[d]

ArcCos[(Cos[d] - Sin[ph1] Sin[ph2])/Cos[ph1]/Cos[ph2]]

dth[d_, ph1_, ph2_] = ArcCos[Sec[ph1] Sec[ph2] (Cos[d] - Sin[ph1] Sin[ph2])]

dth[d1, ph1, ph2]/dth[d2, ph1, ph2]

dth[1, 10*Degree, 20.*Degree]

no, because distance from 10 to 20 is fixed or something

dth[11*Degree, 10*Degree, 20.*Degree] is 4.75167 degs

pythag would say: 10^2 + x^2 = 11^2 so x = 4.58258ish degrees of lat
or 4.87668 after adjusting for cosine 15 deg is better adjustment

15.331 = perfect degree

dest[d_, ph1_, ph2_] = Sqrt[d^2-(ph2-ph1)^2]/Cos[(ph1+ph2)/2]

for 631km = 1/10 earth radii with ph1 at 35 deg, ph2 wandering from
.... 29 to 41?

dth[1/10., 35*Degree, 35*Degree]/Degree
dest[1/10., 35*Degree, 35*Degree]/Degree

Plot[dth[1/10, 35*Degree, n*Degree]/Degree, {n,29,41}]

Plot[dest[1/10, 35*Degree, n*Degree]/Degree-dth[1/10, 35*Degree, n*Deg
ree]/Degree, {n,29,41}]

Timing[Table[dth[1/10, 35*Degree, n*Degree]/Degree, {n,29,41,.01}]];

Table[{n, dth[1/10, 35*Degree, n*Degree]/Degree}, {n,29,41,.5}]

(* given a lat and distance in earth radii, find the delta theta at
each possible lat *)

(* to do: allow changing increment *)

t1139[d_, lat_] := Table[{lat2, dth[d, lat, lat2]}, 
 {lat2, lat-d, lat+d, .04*Degree}]

t1146 = t1139[1/10, 35*Degree]/Degree

Fit[t1146, {1,x,x^2}, x]

Fit[t1146, {1,x^2}, x]

Factor[Fit[t1139[1/10, 25*Degree]/Degree, {1,x,x^2}, x]]

Factor[Fit[t1139[1/20, 25*Degree]/Degree, {1,x,x^2}, x]]

Factor[Fit[t1139[3*Degree, 25*Degree]/Degree, {1,x,x^2}, x]]

Factor[Fit[t1139[3*Degree, 25*Degree]/Degree, {1,(x-28),(x-22),
 (x-22)*(x-28)}, x]]

t1156 = t1139[3*Degree, 25*Degree]/Degree

Table[{ i[[1]]/(i[[1]]-22)/(i[[1]]-28), i[[2]]}, {i, t1156}]

(* like t1139 but w/ a central long, note d is total len so div 2 *)

t1210[d_, lon_, lat_] := Table[{lat2, lon-dth[d, lat, lat2]/2,
lon+dth[d, lat, lat2]/2}, {lat2, lat-d, lat+d, .01*Degree}]

t1210[6*Degree, -106.5*Degree, 35*Degree]/Degree

GeoDistance[{35, -106.5}, {40.8, -107.475}] about 649.442 kilometers

 N[6/360*40000] is 666.667 km so about right

let's check 1 deg grid vs .01 using interpolation

t1222[d_, lat_, i_] := Table[{lat2, dth[d, lat, lat2]}, 
 {lat2, lat-d, lat+d, i}]


t1223 = N[t1222[6*Degree, 35*Degree, 1*Degree]/Degree];

t1224 = Interpolation[t1223];

t1225 = N[t1222[6*Degree, 35*Degree, 0.01*Degree]/Degree];

t1226 = Interpolation[t1225];

Plot[{t1224[x], t1226[x]}, {x,29,41}]

t1229 = N[t1222[6*Degree, 35*Degree, 0.001*Degree]/Degree];

Factor[Fit[t1229, {1,x,x^2}, x]]

Factor[Fit[t1229, {1,x,x^2,x^3,x^4}, x]]

t1230 = N[t1222[6*Degree, 35*Degree, 0.0001*Degree]/Degree];

t1231[x_] = Factor[Fit[t1230, {1,x,x^2}, x]]

Plot[{t1231[x], t1226[x]}, {x,29,41}]

t1235[d_, lon_, lat_, i_] := Table[{lat2, lon-dth[d, lat, lat2]/2,
lon+dth[d, lat, lat2]/2}, {lat2, lat-d, lat+d, i}]

(* assuming loxodrome-- no, assuming cylin line *)

t1236[d_, lon1_, lat1_, lon2_, lat2_, i1_, i2_] := 
 Table[t1235[d, lon1+
