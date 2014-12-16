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







