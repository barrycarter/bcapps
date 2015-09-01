(* ternary method and subdivisions *)

f = Function[t,earthangle[t,mercury,venus]];
g = Function[t,Apply[ArcTan,Take[earthvector[t,mercury],2]]]
h = Function[t,Apply[ArcTan,Take[earthvector[t,venus],2]]]

(*
g = Function[t,Apply[ArcTan,Take[posxyz[t,mercury],2]]];
h = Function[t,Apply[ArcTan,Take[posxyz[t,venus],2]]];
*)

(* Plot[{f[t],g[t],h[t]},{t,info[jstart],info[jstart]+365}] *)

p = Plot[f[t],{t,info[jstart],info[jstart]+365*25}];





(* rewriting ternary method so I can debug *)

ternary[a_,b_,f_,eps_] := Module[{t},
 If[Abs[a-b]<eps,Return[{(a+b)/2,f[(a+b)/2]}]];
 t = Table[{x,f[x]},{x,a,b,(b-a)/3}];
 If[t[[2,2]]<=t[[3,2]]<=t[[4,2]],Return[ternary[a,t[[3,1]],f,eps]]];
 If[t[[3,2]]<=t[[2,2]]<=t[[1,2]],Return[ternary[t[[2,1]],b,f,eps]]];
 If[t[[2,2]]<t[[1,2]] && t[[3,2]]<t[[4,2]],
  Return[ternary[t[[2,1]],t[[3,1]],f,eps]]];

 (* let's see what this does *)
 Return[{ternary[a,(a+b)/2,f,eps],ternary[(a+b)/2,b,f,eps]}];
]


t = Partition[Flatten[ternary[info[jstart],info[jstart]+365,f,.001]],2];

p = Plot[f[t],{t,info[jstart],info[jstart]+365}];
p2 = ListPlot[t];

t2 = Partition[Flatten[ternary[info[jstart],info[jend]-1,f,.001]],2];

Graphics[{RGBColor[1,0,0],ListPlot[t],RGBColor[0,0,1],
Plot[f[t],{t,info[jstart],info[jstart]+365}]}]





Show[Graphics[{RGBColor[1,0,0]}],
Plot[f[t],{t,info[jstart],info[jstart]+365}]
]




(* finding mins for first 365 days *)

terntest[a_,b_,f_,eps_] := Module[{t1,t2},

 Print[a,b,f,eps];

 (* find ternary of first half and second half *)
 t1 = ternary[a,(a+b)/2,f,eps];
 Print[t1];
 t2 = ternary[(a+b)/2,b,f,eps];

 Return[{t1,t2}]; 
]

terntest[info[jstart],info[jstart]+365,f,.01]

ternary[info[jstart],info[jstart]+365,f,.01]

(* chosen points:

{info[jstart],info[jstart]+1/3*365,info[jstart]+2/3*365,info[jstart]+3/3*365};







*)

