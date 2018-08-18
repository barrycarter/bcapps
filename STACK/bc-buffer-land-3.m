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


