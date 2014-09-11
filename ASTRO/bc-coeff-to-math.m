(* converts Chebyshev coefficient lists to functions Mathematica can use *)

(* the coeffs for mercury [can also do with initfile] *)

(* epoch is 2433264.5 1949-12-14 00:00:00 *)

(* Unix epoch is 2440587.500000 1970-01-01 or day 7323 in file *)

<</home/barrycarter/20140823/raw-jupiter.m

(* N to speed things up *)
test0 = Partition[Partition[N[coeffs],ncoeffs],3];

test0 = Partition[Partition[coeffs,ncoeff],3];

Table[x0[t_ /; Evaluate[t>=(n-1)*ndays && t<n*ndays]] =
 chebyshev[test0[[n,1]], 2*Mod[t,ndays]/ndays-1], {n,1,Length[test0]}];

Plot[x0[t],{t,0,365*12}]

(* for jupiter below *)

max0 = t /. NMaximize[x0[t],{t,400,500}][[2]]
min0 = t /. NMinimize[x0[t],{t,1500,3500}][[2]]
mean0 = Mean[{x0[max0],x0[min0]}]
mid0 = Mean[{max0,min0}]
Plot[(x0[t]-mean0)/(x0[max0]-mean0),{t,max0,min0}]
test1[t_] = ArcCos[(x0[t]-mean0)/(x0[max0]-mean0)]
Plot[test1[t],{t,max0,min0},PlotRange->All,AxesOrigin->{max0,0}]
ax[t_] = RationalInterpolation[test1[t], {t,6,4}, {t,max0,min0}]
Plot[{Cos[ax[t]]*(x0[max0]-mean0)+mean0-x0[t]},{t,max0,min0}]
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












