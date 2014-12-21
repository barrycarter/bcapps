(* determining orbits/etc directly from chebyshev polynomials *)

goal = 504;
target = 5;

(* the chebyshev interval for goal/target *)

days = 64800/86400;

(* min and max days *)

{mind,maxd} = {16436,16436+365};

s[t_] := s[t] = {eval[x,goal,target,t],
                 eval[y,goal,target,t],
                 eval[z,goal,target,t]};

(* TODO: could automate this if xyz -> 123 *)

ds[t_,x] := D[poly[x,goal,target,t][w],w] /. w -> t;
ds[t_,y] := D[poly[y,goal,target,t][w],w] /. w -> t;
ds[t_,z] := D[poly[z,goal,target,t][w],w] /. w -> t;

(* this is actually necessary due to the way Mathematica evaluates things *)

(* maybe canonize this *)

halfbrent[f_,a_,b_] := Module[{x},
 If[Sign[f[a]]==Sign[f[b]], Null, FindRoot[f[x]==0, {x,(a+b)/2}][[1,2]]]];

orbits = DeleteCases[Table[halfbrent[ds[#,x]&,n,n+days],{n,mind,maxd,days}],
 Null];

(* sinusoidal per orbit? *)

(* orbit 1-3:

-20651.27668321753 - 1.8824113854248188*^6*Cos[t] + 
 6899.6680875134725*Cos[2*t] - 632.6379375891108*Sin[t] + 
 294.63017883572223*Sin[2*t]

3-5:

-20483.31651548642 - 1.882444427937524*^6*Cos[t] + 
 6824.560490025375*Cos[2*t] - 726.9126767311149*Sin[t] + 
 312.10396343329813*Sin[2*t]

5-7:

-20538.254332570243 - 1.8824250548640601*^6*Cos[t] + 
 6828.791630127502*Cos[2*t] - 549.7407285580508*Sin[t] + 
 366.23122174650985*Sin[2*t]

for y coord, 1-3:

-717.4688724487646 + 11341.366000220029*Cos[t] - 337.21051373884205*Cos[2*t] - 
 1.7025619879753718*^6*Sin[t] + 6152.694462515883*Sin[2*t]

orbit 3-5:

-679.2091624915469 + 11330.921948249485*Cos[t] - 295.75951597623737*Cos[2*t] - 
 1.7024574673605163*^6*Sin[t] + 6203.082067851522*Sin[2*t]

orbit 5-7:

-846.5980797357088 + 11376.768469980052*Cos[t] - 362.4513177501455*Cos[2*t] - 
 1.7025000512645582*^6*Sin[t] + 6235.586569178603*Sin[2*t]

z coord, 1-3:

-646.3004075231424 - 22716.223675402813*Cos[t] - 56.17395161269177*Cos[2*t] - 
 803490.4052325464*Sin[t] + 2907.0012851100005*Sin[2*t]

3-5:

-625.3981298411327 - 22716.13827471791*Cos[t] - 37.9471062227489*Cos[2*t] - 
 803441.9376967564*Sin[t] + 2930.9031484759403*Sin[2*t]

5-7:

-706.3031583001397 - 22688.507950472438*Cos[t] - 69.25097930857497*Cos[2*t] - 
 803459.579577616*Sin[t] + 2946.758737038512*Sin[2*t]

*)

a = orbits[[5]];
b = orbits[[7]];
n = 100;

t1806 = Table[{(t-a)/(b-a)*2*Pi,s[t][[3]]},{t,a,b,(b-a)/(n-1)}];

coss = Flatten[Table[{Cos[n*t],Sin[n*t]},{n,0,2}]]

f1832 = Fit[t1806,coss,t]

Plot[{f1832-s[t/2/Pi*(b-a)+a][[3]]}, {t,0,2*Pi},PlotRange->All]

poly = Table[t^i,{i,0,25}]

f1821 = Fit[t1806,poly,t]

Plot[{f1821,s[t][[1]]},{t,a,b}]

Plot[{f1821},{t,a,b}]
Plot[{s[t][[1]]},{t,a,b}]

orbit[n_] := orbit[n] = mod[s, orbits[[n*2+1]], orbits[[n*2+3]]];

(* testing the matrix *)

ParametricPlot3D[s[t],{t,orbits[[3]],orbits[[5]]}]

ParametricPlot3D[orbit[1][[1]].(s[t]-orbit[1][[2]]),
 {t,orbits[[3]],orbits[[5]]}]

Plot[(Inverse[orbit[1][[1]]].s[t])[[3]],{t,orbits[[3]],orbits[[5]]}]

(*** CUT HERE *** (above this is quasi-useful) *)

(* given a Chebyshev polynomial, return its min/max between -1 and 1
if it has one *)

chebyshevMinMax[f_] := Module[{d,d0,d1},
 d[x_] = D[f[x],x];

 (* no minmax this interval *)
 If[Sign[d[-1]]==Sign[d[1]], Return[]];

 (* negative 2nd derivative, so local max *)
 If[Sign[d[-1]]>Sign[d[1]],Return[FindMaximum[f[x],{x,0}]]];

 (* local min *)
 If[Sign[d[-1]]<Sign[d[1]],Return[FindMinimum[f[x],{x,0}]]];

];

t6 = Table[Function[w,Evaluate[{
 parray[x,1,0][[i]],parray[y,1,0][[i]],parray[z,1,0][[i]]
}]], {i,1,Length[parray[x,1,0]]}];

(* sample usage: t6[[5]][-1], not t6[[5,1]][-1] *)

t0 = Table[Function[w,Evaluate[parray[x,1,0][[i]]]],
 {i,1,Length[parray[x,1,0]]}];

t1 = Table[{i,chebyshevMinMax[t0[[i]]]},{i,1,Length[t0]}];

t2 = Map[chebyshevMinMax,t0];

t3 = DeleteCases[t2,Null];

t4 = Table[i[[1]],{i,t3}];

t5 = Transpose[Partition[t4,2]];

ListPlot[t5[[2]]]







