(* converts Chebyshev coefficient lists to functions Mathematica can use *)

(* the coeffs for mercury [can also do with initfile] *)

<</home/barrycarter/20140823/raw-mercury.m

test0 = Partition[Partition[coeffs,14],3];



x[t_] = Piecewise[Table[{chebyshev[Take[coeffs,{14*n+1,14*n+14}],t],
t>=n*ndays && t<=(n+1)*ndays}, {n,0,5}]]






