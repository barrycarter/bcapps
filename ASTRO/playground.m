(* based on the output of bc-read-cheb.pl for mercury x values 2014 *)

(* this is the file with the output of bc-read-cheb.pl *)
<</tmp/math.m

jds = mercury[x][1][[1]]
jde = mercury[x][48][[2]]

(* the first 2 list elts are start/end Julian date *)

tab = Table[Function[t,Evaluate[
Sum[mercury[x][i][[n]]*ChebyshevT[n-3,t], {n,3,Length[mercury[x][i]]}]]],
{i,1,48}]

(* trivial function that converts a number from [s,e] to [-1,1] *)
f1[t_,s_,e_] = 2*(t-s)/(e-s)-1
(* its inverse: [-1,1] to [s,e] *)
f2[t_,s_,e_] = s + (t+1)*(e-s)/2

g[t_] = Piecewise[
Table[{tab[[i]][f1[t,mercury[x][i][[1]],mercury[x][i][[2]]]], 
 mercury[x][i][[1]] <= t <= mercury[x][i][[2]]}, {i,1,Length[tab]}]
]

Plot[g[t],{t,jds,jde}]

<</home/barrycarter/BCGIT/MATHEMATICA/cheb1.m

(* coeffs stretched to length 15 (my fault when writing cheb1) *)

chebcoff[n_] := PadRight[Take[mercury[x][n], {3,16}],15]

(* combining in pairs *)

t3 = Table[Take[cheb1[chebcoff[i],chebcoff[i+1]],14],{i,1,47,2}]

t4 = Table[{list2cheb[t3[[i]]][
 f1[t, mercury[x][i*2-1][[1]], mercury[x][i*2][[2]]]
],
 mercury[x][i*2-1][[1]] <= t <= mercury[x][i*2][[2]]}, {i,1,Length[t3]}]

k[t_] = Piecewise[t4]

Plot[k[t]-g[t],{t,jds,jde},PlotRange->All]

(* intentionally chopping at 14, though cheb1 gives 30 *)

test1[x_] = list2cheb[Take[cheb1[chebcoff[1],chebcoff[2]],14]]

test2[x_] = test1[f1[x,jds,jds+16]]

Plot[{test2[x]-g[x]},{x,jds,jds+16}]

PadRight[mercury[x][1],15]
PadRight[mercury[x][2],15]

Plot[{tab[[1]][t*2-1],tab[[2]][t*2+1]},{t,-1,1}]
showit

f[t_] = Piecewise[{{tab[[1]][t], t <= 1}, {tab[[2]][t-2], t > 1}}]
Plot[f[x],{x,-1,3}]
showit

g[t_] = Piecewise[Table[{tab[[i]][t+2-2*i], t < -1 + 2*i},{i,1,Length[tab]}]]

Plot[g[t],{t,-1,95}]
