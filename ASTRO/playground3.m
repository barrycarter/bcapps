(* determining orbits/etc directly from chebyshev polynomials *)

s[t_] := s[t] = {eval[x,1,0,t],eval[y,1,0,t],eval[z,1,0,t]};

(* can only do this one coord at a time, else things break *)

sderv[t_] := {D[poly[x,1,0,t][w],w] /. w -> t,
              D[poly[y,1,0,t][w],w] /. w -> t,
              D[poly[z,1,0,t][w],w] /. w -> t};

(* TODO: could automate this if xyz -> 123 *)

ds[t_,x] := D[poly[x,1,0,t][w],w] /. w -> t;
ds[t_,y] := D[poly[y,1,0,t][w],w] /. w -> t;
ds[t_,z] := D[poly[z,1,0,t][w],w] /. w -> t;

(* this is actually necessary due to the way Mathematica evaluates things *)

(* the chebyshev interval for mercury *)

days = 8;

(* min and max days *)

{mind,maxd} = {0,365*9};

(* maybe canonize this *)

halfbrent[f_,a_,b_] := Module[{x},
 If[Sign[f[a]]==Sign[f[b]], Null, FindRoot[f[x]==0, {x,(a+b)/2}][[1,2]]]];

orbits = DeleteCases[Table[halfbrent[ds[#,x]&,n,n+days],{n,mind,maxd,days}],
 Null];

(* testing *)

t0 = orbits[[11]];
t1 = orbits[[13]];

epsilon = 10^-5;

findminleft[(s[#][[1]])&, t0-epsilon, t1+epsilon]

mod[s, t0, t1]

orbit[n_] := orbit[n] = mod[s, orbits[[n*2+1]], orbits[[n*2+3]]];

orbit[1]

(* this is probably not libworthy: given a function and its
derivative, split [a,b] into n intervals, find maxs and mins and
return the first max followed by the first min, assuming no 2 extrema
will occur in any (a-b)/n interval *)

m0519[f_,df_,a_,b_,n_] := Module[{tab,roots},

 (* table of intervals *)
 tab = Table[{a+(b-a)*(i-1)/n, a+(b-a)*i/n}, {i,1,n}];

 (* values where df is 0 *)
 roots = t /. 
         DeleteCases[Table[If[Sign[df[tab[[i,1]]]]==Sign[df[tab[[i,2]]]], Null,
         FindRoot[df[t], {t, Mean[tab[[i]]]}]], {i,1,n}], Null];
]


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







