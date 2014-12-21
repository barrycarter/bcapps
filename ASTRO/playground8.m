(* mercurys orbit broken down into sin/cos *)

goal = 1;
target = 0;

(* the chebyshev interval for goal/target *)

days = 8;

(* min and max days *)

{mind,maxd} = {0,365*15};

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

a = orbits[[39]];
b = orbits[[41]];
n = 100;

t1806 = Table[{(t-a)/(b-a)*2*Pi,s[t][[3]]},{t,a,b,(b-a)/(n-1)}];

t1921 = Table[{(t-a)/(b-a)*2-1,s[t][[3]]},{t,a,b,(b-a)/(n-1)}];

coss = Flatten[{Table[{Cos[n*t],Sin[n*t]},{n,1,10}],1}]
f1832 = Fit[t1806,coss,t]

(* below does NOT include constant term! *)
coeffs = Table[Coefficient[f1832,i],{i,Drop[coss,-1]}]

poly = Flatten[Table[t^i,{i,0,16}]]

f1921 = Fit[t1921,poly,t]

Plot[{f1832-s[t/2/Pi*(b-a)+a][[3]]}, {t,0,2*Pi},PlotRange->All]

(* generalizing; note this assumes s[t] and orbits are global = bad *)

coeffs[i_] := coeffs[i] = Module[{a,b,n,coss,t,tab,f,j,c},
 coss = Flatten[{Table[{Cos[n*t],Sin[n*t]},{n,1,10}],1}];
 a = orbits[[i*2-1]];
 b = orbits[[i*2+1]];
 n = 100;
 tab = Table[{(t-a)/(b-a)*2*Pi,s[t][[1]]},{t,a,b,(b-a)/(n-1)}];
 f = Fit[tab,coss,t];
 c = CoefficientList[f,t][[1]];
 Flatten[{Table[Coefficient[f,j],{j,Drop[coss,-1]}], c}]
];

t0812 = Table[coeffs[i],{i,1,Floor[(Length[orbits]-1)/2]}]

t0813 = Transpose[t0812];

coss = Flatten[{Table[{Cos[n*t],Sin[n*t]},{n,1,10}],1}];

Plot[Drop[coss,-1].coeffs[5],{t,0,2*Pi}]

a = orbits[[5*2-1]];
b = orbits[[5*2+1]];

Plot[s[t/2/Pi*(b-a)+a][[1]], {t,0,2*Pi}]

Plot[{Drop[coss,-1].coeffs[5],s[t/2/Pi*(b-a)+a][[1]]}, {t,0,2*Pi}]

