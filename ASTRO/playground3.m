(* determining orbits/etc directly from chebyshev polynomials *)

(* min/max z values of mercury's orbit *)

t0450 = Table[NMaximize[{Abs[eval[z,1,0,t]],t>n,t<n+8},t],{n,0,36,8}];

t0450 = Table[NMaximize[{eval[z,1,0,t],t>n,t<n+8},t],{n,0,365,8}];

dervz[t_] := D[poly[z,1,0,t][w],w] /. w -> t;


FindRoot[dervz[t]==0,{t,0,8}]

(* below works *)

t0516 = t /. DeleteCases[Table[If[Sign[dervz[n]] != Sign[dervz[n+8]],
FindRoot[dervz[t]==0,{t,n+4}], 0], {n,0,365*9.5+44,8}],0]

(* length is 80, so this is 40 orbits, and its actually not super
close to mercury's true orbital period, hmmm, about a day off! *)

(t0516[[-1]]-t0516[[1]])/Length[t0516]

(* now the z values themselves *)

t0525 = Table[{t,eval[z,1,0,t]},{t,t0516}]

(* the above are highly asymmetrical *)

s[t_] := s[t] = {eval[x,1,0,t],eval[y,1,0,t],eval[z,1,0,t]};

(* highest z values *)

hz1 = s[t0525[[1,1]]];
hz2 = s[t0525[[3,1]]];

(* and the rotation angle *)

ArcTan[hz1[[1]],hz1[[2]]]

(* minima (actually maxima, but OK) *)

minima = Table[t0525[[i]],{i,1,Length[t0525],2}];

(* table of positions at minima *)

pos0657 = Table[{i[[1]],s[i[[1]]]},{i,minima}]

atans = Table[{i[[1]], ArcTan[i[[2,1]],i[[2,2]]]}, {i,pos0657}]

(* and the maximal z values [this is inaccurate since I plan to adjust] *)












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







