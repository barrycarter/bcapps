(* converts Chebyshev coefficient lists to functions Mathematica can use *)

(* the coeffs for mercury [can also do with initfile] *)

(* epoch is 2433264.5 1949-12-14 00:00:00 *)

(* Unix epoch is 2440587.500000 1970-01-01 or day 7323 in file *)

<</home/barrycarter/20140823/raw-mercury.m

(* N to speed things up *)
test0 = Partition[Partition[N[coeffs],14],3];

test0 = Partition[Partition[coeffs,14],3];

Table[xpoly[n, t_] = chebyshev[test0[[n,1]],t], {n,1,Length[test0]}];

x0[t_] = Piecewise[Table[
 {chebyshev[test0[[n,1]], 2*Mod[t,ndays]/ndays-1],
 t>=(n-1)*ndays && t<n*ndays}, 
{n,1,Length[test0]}]];

cond[n_] = t>=(n-1)*ndays && t<n*ndays

f[x_] = x^2 /; x>0

f[x_] = If[x>0,x^2]
f[x_] = If[x<0,-x]

f[x_ /; x>0] = x^2



Table[
 x0[t_ /; t>=(n-1)*ndays && t<n*ndays] = 
 chebyshev[test0[[n,1]], 2*Mod[t,ndays]/ndays-1]
, {n,1,10}]


Table[
 x0[t_ /; Evaluate[cond[n]]] =
 chebyshev[test0[[n,1]], 2*Mod[t,ndays]/ndays-1]
, {n,1,10}]



Table[x0[t_] = chebyshev[test0[[n,1]], 2*Mod[t,ndays]/ndays-1] /;
 t>=(n-1)*ndays && t<n*ndays, {n,1,10}]




x0[t_] = xpoly[Floor[t/ndays]+1, 2*Mod[t,ndays]/ndays-1]

(* possibly faster method below *)

test1[t_] = {Floor[t/ndays]+1, 2*Mod[t,ndays]/ndays-1}

Table[xfunc[t] = test0[[t,1]], {t,1,10}]

test2[t_] = xfunc[Floor[t/ndays]+1]

test2[t_] = chebyshev[xfunc[Floor[t/ndays]+1], t]



x0[t_] = chebyshev[xfunc[Floor[t/ndays]+1], 2*Mod[t,ndays]/ndays-1]

x0[t_] := chebyshev[test0[[Floor[t/ndays]+1,1]], 2*Mod[t,ndays]/ndays-1]
y0[t_] := chebyshev[test0[[Floor[t/ndays]+1,2]], 2*Mod[t,ndays]/ndays-1]
z0[t_] := chebyshev[test0[[Floor[t/ndays]+1,3]], 2*Mod[t,ndays]/ndays-1]

(* above does not operate as function, so... *)

x0[t_] = chebyshev[test0

MiniMaxApproximation[x0[t],{t,{0,88},3,3}]

test1 = Integrate[ax[t],{t,0,88}]/88.

ax[t_]=RationalInterpolation[x0[t]-test1, {t,3,3}, {t,0,88}]

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












