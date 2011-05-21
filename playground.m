(* playground for Mathematica *)

showit := Module[{}, 
Export["/tmp/math.jpg",%, ImageSize->{800,600}]; Run["display /tmp/math.jpg&"]]

h00[t_] = (1+2*t)*(1-t)^2
h10[t_] = t*(1-t)^2
h01[t_] = t^2*(3-2*t)
h11[t_] = t^2*(t-1)

altintfuncalc[f_, t_] := Module[
 {xvals, yvals, xint, tisin, tpos, m0, m1, p0, p1},

 (* figure out x values *)
 xvals = Flatten[f[[3]]];

 (* and corresponding y values *)
 yvals = Flatten[f[[4,3]]];

 (* HACK: for some reason, t1 is bizarre *)
// yvals = Flatten[f[[4]]];


 (* and size of each x interval; there are many other ways to do this *)
 (* <h>almost all of which are better than this?</h> *)
 xint = (xvals[[-1]]-xvals[[1]])/(Length[xvals]-1);

 (* for efficiency, all vars above this point should be cached *)

 (* which interval is t in?; interval i = x[[i]],x[[i+1]] *)
 tisin = Min[Max[Ceiling[(t-xvals[[1]])/xint],1],Length[xvals]-1];

Print["TISIN ",tisin];
Print["XVALS ",xvals];
Print["YVALS ",yvals];

 (* and the y values for this interval, using Hermite convention *)
 p0 = yvals[[tisin]];
 p1 = yvals[[tisin+1]];

 (* what is t's position in this interval? *)
 tpos = (t-xvals[[tisin]])/xint;

 (* what are the slopes for the intervals immediately before/after this one? *)
 (* we are assuming interval length of 1, so we do NOT divide by int *)
 m0 = p0-yvals[[tisin-1]];
 m1 = yvals[[tisin+2]]-p1;

 (* return the Hermite approximation *)
 (* <h>Whoever wrote the wp article was thinking of w00t</h> *)
 h00[tpos]*p0 + h10[tpos]*m0 + h01[tpos]*p1 + h11[tpos]*m1
]

t1 = Interpolation[Table[x*x,{x,1,10}]]

altintfuncalc[t1, 9.5]


Exit[]

(* if we map ra/dec as theta, r (r= 90+dec), do we have something? 
(it's at least only 2D *)

dec[t_] = 23*Sin[t*2*Pi/365]
ra[t_] = t/365*24/24*2*Pi

Plot[{ra[t],dec[t]},{t,0,365}]

x[t_] = (90+dec[t])*Sin[ra[t]]
y[t_] = (90+dec[t])*Cos[ra[t]]

Plot[x[t],{t,0,365}]
Plot[y[t],{t,0,365}]

Exit[]

(* if we have lots of data, can we "compress" it in an odd way? *)

(* trying to do 10 years at a time slow things down a bit, so maybe 1 year *)

data = Take[data, 10000];

(* start with dec *)

moondec = Table[{i[[1]], i[[3]]}, {i,data}];

datareduce[data_, n_] := Module[{halfdata, inthalfdata, tabhalfdata, origdata},
 halfdata = Take[data, {1,Length[data],2^n}];
Print["halfdata complete"];
 inthalfdata = Interpolation[halfdata];
Print["inthalfdata complete"];
 tabhalfdata = Table[inthalfdata[data[[i,1]]], {i, 1, Length[data]}];
Print["tabhalfdata complete"];
 Return[tabhalfdata];
]

t1 = datareduce[moondec, 1];
t2 = Table[moondec[[i,2]], {i, 1, Length[data]}];
t3 = t1-t2;

(* vaguely bad that I'm using data as a parameter, but won't cause
Mathematica problem *)

(* take each 2^nth piece of data *)
halfdata[data_, n_] := Take[data, {1,Length[data],2^n}]

(* interpolate it *)
inthalfdata[data_, n_] := Interpolation[halfdata[data,n]]

(* new data *)
tabhalfdata[data_, n_] := 
 Table[inthalfdata[data,n][data[[i,1]]], {i, 1, Length[data]}]

(* and compare *)
maxdiff[data_, n_] := Max[tabhalfdata[data,n]];

moondechd = halfdata[moondec,1];





mindata = Table[{i, data[[i]]}, {i,1,Length[data],50}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],500}]

mindata = Table[{i, data[[i]]}, {i,1,Length[data],5000}]

amindata = Interpolation[mindata]
amindata = Interpolation[mindata, InterpolationOrder->1]
amindata = Interpolation[mindata, InterpolationOrder->2]
amindata = Interpolation[mindata, InterpolationOrder->0]
amindata = Interpolation[mindata, InterpolationOrder->5]
amindata = Interpolation[mindata, InterpolationOrder->17]

atab = Table[amindata[x], {x,1,Length[data]}]

ListPlot[data-atab]

Max[Abs[data-atab]]



Exit[]

mod[x_] := Module[{coeff,a},
 coeff= {1,2,3};
 Function[y, Evaluate[x+coeff[[1]]+y]]
]

mod[7]


Exit[]

(* table of inverse normal curve for NADEX vols *)

inv[x_] = y /. Solve[CDF[NormalDistribution[0,1]][y]==x,y][[1]]

Flatten[Table[{N[x,4],N[inv[x],10]},{x,0,1,25/10000}]
 ] >> /home/barrycarter/BCGIT/data/inv-norm-as-list.txt

Exit[]

(* how much worse is linear interpolation for moonpos? *)

t = << /home/barrycarter/BCGIT/sample-data/manytables.txt

Flatten[t[[1,3,3,3]]]

(* the xyz vals from Hermite approx, for 2011 *)

hxval[r_] := t[[1,1,3]][r]
hyval[r_] := t[[1,2,3]][r]
hzval[r_] := t[[1,3,3]][r]

hdec[r_] := ArcSin[hzval[r]/Sqrt[hxval[r]^2+hyval[r]^2+hzval[r]^2]]/Degree

Plot[hdec[r],{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

(* and the domain, range for the x values of the moon *)

Flatten[t[[1,1,3,3]]]
Flatten[t[[1,1,3,4,3]]]

xm1 = Table[{t[[1,1,3,3,1,i]], t[[1,1,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
ym1 = Table[{t[[1,1,3,3,1,i]], t[[1,2,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]
zm1 = Table[{t[[1,1,3,3,1,i]], t[[1,3,3,4,3,i]]}, {i, Length[t[[1,1,3,3,1]]]}]

flatx = Interpolation[xm1, InterpolationOrder -> 1]
flaty = Interpolation[ym1, InterpolationOrder -> 1]
flatz = Interpolation[zm1, InterpolationOrder -> 1]

flatdec[r_] := ArcSin[flatz[r]/Sqrt[flatx[r]^2+flaty[r]^2+flatz[r]^2]]/Degree

Plot[{flatx[r] - hxval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flaty[r] - hyval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatz[r] - hzval[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]

Plot[{flatdec[r],hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]}]
Plot[{flatdec[r]-hdec[r]},{r, FromDate[{2011,1,1}], FromDate[{2012,1,1}]},
 PlotRange->All]

(* trivial difference, so could've just used linear *)

(* Hermite broken, fixing? *)

l={3.391804676434298,3.183960097542073,2.9043571833527966,2.5667537942969005}

l1=Interpolation[l]
d1[x_] = D[l1[x],x]
d2 = D[d1]

Plot[{l1[x],d1[x]}, {x,1,4}]
Plot[{d1[x]}, {x,1,2}]

Plot[l1[x] - l1[Floor[x]]*h00[x-Floor[x]] -
     h01[x-Floor[x]]*l1[Ceiling[x]]
, {x,1,2}]

Plot[l1[x],{x,1,4}]

Plot[D[l1][y], {y,1,2}]

altintfuncalc[l1, 2.5]

(* confirmed that my implementation of hermite above is broken *)

Plot[{h00[t], h01[t], h10[t], h11[t]}, {t,0,1}]

(* list = {1,4,9,16,25,36} *)

list = Table[x*x*x,{x,1,6}]

func = Interpolation[list]

Plot[func[x], {x,1,6}]

Plot[func[x]-x*x*x, {x,1,6}]

test1[x_] := func[x] - h00[x-Floor[x]]*list[[Floor[x]]] - 
 h01[x-Floor[x]]*list[[Floor[x+1]]]

Plot[test1[x],{x,1,6}]

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == 1.54688,
 h10[.75]*m0 + h11[.75]*m1 == -5.48438
}, {m0,m1}
]

(slopes 27 and 48, NOT 28 and 49 as expected)

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == 0.421875,
 h10[.75]*m0 + h11[.75]*m1 == -3.23438
}, {m0,m1}
]

(slopes 12 and 27, vs 13 and 28 as expected)

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[2.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[2.75]
}, {m0,m1}
]

slopes 3 and 12; expected 1 and 13

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[4.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[4.75]
}, {m0,m1}
]

slopes 48 and 75 vs 49 and 76

Solve[{
 h10[.125]*m0 + h11[.125]*m1 == test1[4.125],
 h10[.375]*m0 + h11[.375]*m1 == test1[4.375]
}, {m0,m1}
]

Solve[{
 h10[.25]*m0 + h11[.25]*m1 == test1[2.25],
 h10[.75]*m0 + h11[.75]*m1 == test1[2.75]
}, {m0,m1}
]

slopes 5 and 30.5 vs 2.5, 28 my calc [when first number is 22]

making it 200

my slopes: -86.5, 28

theirs: -54.3333 and 60.1667

32.167 higher in both cases

so 22 -> 2.5, 200 -> 32.167

67 higher in another case

Table[list[[i]]-list[[j]], {i,1,Length[list]}, {j,1,Length[list]}]

between 8,27 what does my way give you?

h00[.75]*8 + h01[.75]*27 + h10[.75]*13 + h11[.75]*28

(this is for 2.75)

h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28

yields: 8 + 13*t + 3*t^2 + 3*t^3

h00[t-2]*8 + h01[t-2]*27 + h10[t-2]*13 + h11[t-2]*28

-30 + 37*t - 15*t^2 + 3*t^3

where as using their #s

h00[t]*8 + h01[t]*27 + h10[t]*12 + h11[t]*27

yields (2+t)^3


h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28 - (t+2)^3

t*(1 - 3*t + 2*t^2) <- hermite polynomial?

left[t_] = t*(1 - 3*t + 2*t^2)

Simplify[left[t] - h00[t]]
Simplify[left[t] - h01[t]]
Simplify[left[t] - h10[t]]
Simplify[left[t] - h11[t]]

h00 is 1 - 3*t^2 + 2*t^3

while leftover is

t - 3*t^2 + 2*t^3

(interesting)

Solve[h00[t]*8 + h01[t]*27 + h10[t]*m0 + h11[t]*m1 - (t+2)^3 == 0, {m0,m1}]

(3^3-1.5^3)/2

Solve[3^3-x^3 == 24,x]

Interpolation[{8,27,64,125}]

Plot[5*h10[t] + 7*h11[t], {t,0,1}]


myway[t_] = h00[t]*8 + h01[t]*27 + h10[t]*13 + h11[t]*28

hmmm, why doesn't 28 show up in derv

myway[t_] = h00[t]*27 + h01[t]*8 + h10[t]*28 + h11[t]*13

test1[t_] = h10[t]*28 + h11[t]*13

Plot[D[test1][t], {t,0,1}]

28*(1 - t)^2*t + 13*(-1 + t)*t^2 <- derv of my way

Plot[27*(1 - t)^2*t + 12*(-1 + t)*t^2, {t,0,1}]

Plot[(27*(1 - t)^2*t + 12*(-1 + t)*t^2)-D[test1][t], {t,0,1}]

derv1[t_] = D[test1[t],t]

derv2[t_] = D[derv1[t],t]

dtheir[t_] = D[27*(1 - t)^2*t + 12*(-1 + t)*t^2, t]
d2their[t_] = D[dtheir[t],t]

(* wow, mathematica lets you do general interpolation! *)

f = Interpolation[{a,b,c,d}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

f = Interpolation[{a,b,c,d,e,f}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[3+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3+3/4]
}, {m0,m1}
]




Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[2+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[2+3/4]
}, {m0,m1}
]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[3+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[3+3/4]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {8, y1},
 {9, y2},
 {10, y3},
 {11, y4},
 {12, y5}
}]


Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[9+1/4],
 h10[3/4]*m0 + h11[3/4]*m1 == f[9+3/4]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {7.01, y1},
 {7.02, y2},
 {7.03, y3},
 {7.04, y4},
 {7.05, y5}
}]

Solve[{
 h10[1/4]*m0 + h11[1/4]*m1 == f[7.02+1/400],
 h10[3/4]*m0 + h11[3/4]*m1 == f[7.02+3/400]
}, {m0,m1}
]

f = Interpolation[{
 {7, y0},
 {8, y1},
 {15, y2},
 {22, y3},
 {115, y4},
 {116, y5}
}]
