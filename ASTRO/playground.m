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

Plot[g[f2[t,jds,jde]], {t,-1,1}]

h[t_] = g[f2[t,jds,jde]]

coeff[n_] := coeff[n] =
2/Pi*NIntegrate[g[f2[x,jds,jde]]/Sqrt[1-x^2]*ChebyshevT[n,x],{x,-1,1}]

t2 = Table[coeff[n],{n,0,39}]

Sum[t2[[i]]*ChebyshevT[i-1,x],{i,1,Length[t2]}]

j[t_] = Sum[t2[[i]]*ChebyshevT[i-1,t],{i,1,Length[t2]}]

<</home/barrycarter/BCGIT/MATHEMATICA/cheb1.m

(* coeffs stretched to length 15 (my fault when writing cheb1) *)

chebcoff[n_] := PadRight[Take[mercury[x][n], {3,16}],15]

(* combining in pairs *)

t3 = Map[list2cheb,Take[Table[cheb1[chebcoff[i],chebcoff[i+1]],14],{i,1,47,2}]]

k[t_] = Piecewise[
Table[{t3[[i]][f1[t,mercury[x][i][[1]],mercury[x][i+1][[2]]]], 
 mercury[x][i][[1]] <= t <= mercury[x][i+1][[2]]}, {i,1,Length[t3]}]
]


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
