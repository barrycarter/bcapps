(* converts Chebyshev coefficient lists to functions Mathematica can use *)

(* the coeffs for mercury [can also do with initfile] *)

(* epoch is 2433264.5 1949-12-14 00:00:00 *)

(* Unix epoch is 2440587.500000 1970-01-01 or day 7323 in file *)

<</home/barrycarter/20140823/raw-jupiter.m

part = Partition[Partition[coeffs,ncoeff],3];

(* We may actually need the polys themselves, so store them *)

(* i = 1,2,3 to identify axis *)

Table[poly[n,i,t_] = chebyshev[part[[n,i]],t], {i,1,3}, {n,1,Length[part]}];

xmaxs = Table[Maximize[{poly[n,1,t],t>-1,t<1},t][[1]], {n,1,Length[part]}]
xmax = Max[N[xmaxs]]

xmins = Table[Minimize[{poly[n,1,t],t>-1,t<1},t][[1]], {n,1,Length[part]}]
xmin = Min[N[xmins]]

(* <h>I'm too lazy to write (xmax+xmin)/2</h> *)
xmean = Mean[{xmin,xmax}]

(* TODO: check memory usage, it's getting really high! *)

Table[x0[t_ /; Evaluate[t>=(n-1)*ndays && t<n*ndays]] =
 poly[n,1,2*Mod[t,ndays]/ndays-1], {n,1,Length[part]}];



Table[x0[t_ /; Evaluate[t>=(n-1)*ndays && t<n*ndays]] =
 chebyshev[part[[n,1]], 2*Mod[t,ndays]/ndays-1], {n,1,Length[test0]}];

Table[y0[t_ /; Evaluate[t>=(n-1)*ndays && t<n*ndays]] =
 chebyshev[test0[[n,2]], 2*Mod[t,ndays]/ndays-1], {n,1,Length[test0]}];

Table[z0[t_ /; Evaluate[t>=(n-1)*ndays && t<n*ndays]] =
 chebyshev[test0[[n,3]], 2*Mod[t,ndays]/ndays-1], {n,1,Length[test0]}];

(* Sum of distance from two arbitrary points [find ellipse foci] *)

dist[t_] = Norm[{x0[t],y0[t],z0[t]}-{ax,ay,az}] +
           Norm[{x0[t],y0[t],z0[t]}-{bx,by,bz}]

(* could not solve below *)
NSolve[{dist[0] == dist[1] == dist[2] == dist[3]}, {ax,ay,az,bx,by,bz}]

Plot[ArcTan[x0[t],y0[t]],{t,0,36500}]

test0824[t_] = D[ArcTan[x0[t],y0[t]],t]

Plot[test0824[t],{t,0,365*12}]

Plot[Norm[{x0[t],y0[t],z0[t]}],{t,0,365*100}]

Plot[x0[t],{t,0,365*100}]

Plot[{x0[t],y0[t],z0[t],Norm[{x0[t],y0[t],z0[t]}]},{t,0,365*12}]





testf0[t_] = RationalInterpolation[ArcTan[x0[t],y0[t]],{t,11,0},{t,0,2600}]

Plot[{ArcTan[x0[t],y0[t]]-testf0[t]},{t,0,2600}]



 

Plot[z0[t],{t,7323,7324}]

Plot[x0[t],{t,0,365*12}]

(* for jupiter below *)

max0 = t /. NMaximize[x0[t],{t,400,500}][[2]]
min0 = t /. NMinimize[x0[t],{t,1500,3500}][[2]]
mean0 = Mean[{x0[max0],x0[min0]}]
mid0 = Mean[{max0,min0}]

(* convert [-1,1] to [max0,min0] and vice versa *)

convert[t_] = t*(min0-max0)/2+mid0
convert1[t_] = 2*(t-mid0)/(min0-max0);

(* the normalized function on range -1,1 *)

f[t_] = (x0[convert[t]]-mean0)/(x0[max0]-mean0)
Plot[f[t],{t,-1,1}]

(* first approximation *)

approx1[t_] = 2*ArcCos[f[t]]/Pi-1-t
Plot[approx1[t],{t,-1,1},PlotRange->All]

(* find max error *)

maxerr = NMaximize[approx1[t],{t,-1/2,1/2}][[1]]

(* approx of diff *)

approx2[t_] = approx1[t]-maxerr*Cos[t*Pi/2]

Plot[approx2[t],{t,-1,1}]

(* and next min/max err *)

min2 = NMinimize[approx2[t],{t,-3/4,-1/4}][[1]]
max2 = NMaximize[approx2[t],{t,1/4,3/4}][[1]]
mean2 = Mean[{min2,max2}]

Plot[approx2[t],{t,-1,1}]
approx3[t_] = approx2[t]-(mean2+(max2-mean2)*Sin[t*Pi])

Plot[{approx2[t],approx3[t]},{t,-1,1}]

Plot[{approx1[t],approx3[t]},{t,-1,1}]

Plot[{(x0[max0]-mean0)*
 (f[t]-Cos[(approx1[t]+approx2[t]+approx3[t]+t+1)*Pi/2])},{t,-1,1}]






Plot[test1[t],{t,-1,1},PlotRange->All]

Plot[ArcCos[test1[t]/.0305141],{t,-1,1}]

Plot[{test1[t],Sin[Pi/2*t+Pi/2]*.0305141},{t,-1,1},PlotRange->All]

Plot[{test1[t]-Sin[Pi/2*t+Pi/2]*.0305141},{t,-1,1},PlotRange->All]

(* reverse it? *)

test2[t_] = Cos[(Sin[Pi/2*t+Pi/2]*.0305141+t+1)*Pi/2]

Plot[{f[t],test2[t]},{t,-1,1}]

(* approximate it *)

ax[t_] = RationalInterpolation[test1[t], {t,24,0}, {t,-1,1}]

Plot[{test1[t],ax[t]},{t,-1,1}]

(* test the approximation *)

Plot[{(Cos[Pi/2*(ax[t]+t+1)]-f[t])*(x0[max0]-mean0)},{t,-1,1},PlotRange->All]
showit




Plot[f[t],{t,0,1}]

Plot[(x0[t+mid0]-mean0)/(x0[max0]-mean0),{t,max0-mid0,min0-mid0}]
test1[t_] = ArcCos[(x0[t+mid0]-mean0)/(x0[max0]-mean0)]
ax[t_] = RationalInterpolation[test1[t], {t,6,4}, {t,max0-mid0,min0-mid0}]
ax[t_] = RationalInterpolation[test1[t], {t,1,0}, {t,max0-mid0,min0-mid0}]
Plot[{Cos[ax[t]]*(x0[max0]-mean0)+mean0-x0[t+mid0]},{t,max0-mid0,mid0-min0}]
showit



ax[t_]=RationalInterpolation[x0[t], {t,4,4}, {t,0,88}]
ax[t_]=RationalInterpolation[x0[t], {t,16,0}, {t,0,88}]

Plot[Sin[t/88*2*Pi],{t,0,88}]

Plot[{x0[t+76.7279]/Sin[t/87.9841*2*Pi]}, {t,0,88}]

Plot[{x0[t+76.7279]/Sin[t/87.9841*2*Pi]}, {t,1,43},AxesOrigin->{0,0}]

Plot[ArcSin[x0[t]/5.39982/10^7],{t,0,88}]

(* finding 0s and maxs to do arcsin stuff with *)

max0 = 12.1448
min0 = 50.5263
first0 = 76.7279
firstmax = 100.114
next0 = 118.144

mean0 = Mean[{x0[max0],x0[min0]}]

Plot[(x0[t]-mean0)/(x0[max0]-mean0),{t,max0,min0}]

test1[t_] = ArcCos[(x0[t]-mean0)/(x0[max0]-mean0)]

test1[t_] = ArcCos[x0[t]/Max[x0[max0],-x0[min0]]]

Plot[test1[t],{t,max0,min0},AxesOrigin->{max0,0},PlotRange->All]

ax[t_] = RationalInterpolation[test1[t], {t,4,3}, {t,76.7279,100.114}]

ax[t_] = RationalInterpolation[test1[t], {t,8,0}, {t,76.7279,100.114}]

ax[t_] = RationalInterpolation[test1[t], {t,4,3}, {t,max0,min0}]

Plot[{ax[t]-test1[t]},{t,max0,min0}]

Plot[{Cos[ax[t]]*(x0[max0]-mean0)+mean0-x0[t]},{t,max0,min0}]

{Sin[ax[t]]*x0[100.114]-x0[t]},{t,76.7279,100.114},PlotRange->All]


Plot[{ax[t]-x0[t]}, {t,0,88}]

MiniMaxApproximation[x0[t],{t,{0,88},3,3}]

test1 = NIntegrate[x0[t],{t,0,88}]/88.


Plot[{ax[t]+test1,x0[t]}, {t,0,88}]


(* directly on x0 for speed *)

PadeApproximant[x0[t],{t,16254+7323,3}]

ax[t_]=RationalInterpolation[x0[t], {t,9,9}, {t,16254+7323-183,16254+7323+183}]

ax[t_]=RationalInterpolation[x0[t], {t,4,1}, {t,16254+7323-32,16254+7323+32}]

ax[t_]=EconomizedRationalApproximation[x0[t], 
 {t,{16254+7323-32,16254+7323+32},3,3}]



Plot[{ax[t],x0[t]}, {t,16254+7323-32,16254+7323+32}]

(* just to use unix days *)

x[t_] = x0[t+7323];

x[23646]












