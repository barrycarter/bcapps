(* determining orbits/etc directly from chebyshev polynomials *)

s[t_] := s[t] = {eval[x,1,0,t],eval[y,1,0,t],eval[z,1,0,t]};

pos[x,t_] := s[t][[1]];
pos[y,t_] := s[t][[2]];
pos[z,t_] := s[t][[3]];

(* trying a "centralist" approach again, and will use a and b to find focus *)

derv[x,t_] := D[poly[x,1,0,t][w],w] /. w -> t;
derv[y,t_] := D[poly[y,1,0,t][w],w] /. w -> t;
derv[z,t_] := D[poly[z,1,0,t][w],w] /. w -> t;

tab[var_] := tab[var] = t /. DeleteCases[Table[If[Sign[derv[var,n]] !=
Sign[derv[var,n+8]], FindRoot[derv[var,t]==0,{t,n+4}], 0],
{n,0,365*9.5+44,8}],0];

tab[x];tab[y];tab[z];

poss[i_] := poss[i] = Map[pos[i,#]&, tab[i]];

poss[x];poss[y];poss[z];

(* correction vectors *)

corr = Table[{
 Mean[{poss[x][[i]],poss[x][[i+1]]}],
 Mean[{poss[y][[i]],poss[y][[i+1]]}],
 Mean[{poss[z][[i]],poss[z][[i+1]]}]
}, {i,1,Length[poss[x]],2}]

(* the modified orbit, first orbit *)

s2[t_] := s[t] - corr[[1]];

(* max z for first orbit *)

t0 = tab[z][[1]];

(* the angle at which z reaches max *)

anzmax = ArcTan[s2[t0][[1]],s2[t0][[2]]];

(* and what that angle actually is *)

zmaxang = ArcTan[Norm[Take[s2[t0],2]], s2[t0][[3]]];

(* apply the transform matrix *)

s3[t_] := rotationMatrix[y,-zmaxang].rotationMatrix[z,-anzmax].s2[t];

(* find the min and max for the first and second half-orbits *)

xymaxmin = t /. Transpose[{
NMaximize[{Norm[s3[t]],t>tab[z][[1]],t<tab[z][[2]]}, t],
NMaximize[{Norm[s3[t]],t>tab[z][[2]],t<tab[z][[3]]}, t],
NMinimize[{Norm[s3[t]],t>tab[z][[1]],t<tab[z][[2]]}, t],
NMinimize[{Norm[s3[t]],t>tab[z][[2]],t<tab[z][[3]]}, t]
}][[2]];

(* angle at which the max norm occurs (first one) *)

maxnorm1 = s3[xymaxmin[[1]]];

mna = ArcTan[maxnorm1[[1]],maxnorm1[[2]]];

s4[t_] := rotationMatrix[z,-mna].s3[t];

ParametricPlot[Take[s4[t],2], {t,tab[z][[1]],tab[z][[3]]}]

ParametricPlot[Take[s4[t],2], {t,xymaxmin[[1]],xymaxmin[[2]]}]

(* semimajor and semiminor axes *)

sma = Norm[s4[xymaxmin[[1]]]]
smi = Norm[s4[xymaxmin[[3]]]]

(* eccentricity match is good! *)

ellipseAB2E[sma,smi]

(* matches below are unsurprising since we planned it that way *)

ellipseMA2XY[sma,smi,0]
s4[xymaxmin[[1]]]

ellipseMA2XY[sma,smi,Pi]
s4[xymaxmin[[2]]]

ellipseMA2XY[sma,smi,Pi/2]
s4[Mean[Take[xymaxmin,2]]]

Plot[s4[t][[1]],{t,50.4818,94.6935}]

Plot[ellipseMA2XY[sma,smi,t][[2]],{t,0,Pi}]





















Plot[Norm[s3[t]],{t,tab[z][[1]],tab[z][[3]]}]





(* find average of min/max per orbit *)

Table[
 {x[tab[x][[i]]], x[tab[x][[i+1]]]},
{i,1,Length[tab[x]]}
]



Mean[{tab[x][[i]],tab[x][[i+1]]}],{i,Length[tab[x]],2}]




(* min/max z values of mercury's orbit *)

t0450 = Table[NMaximize[{Abs[eval[z,1,0,t]],t>n,t<n+8},t],{n,0,36,8}];

t0450 = Table[NMaximize[{eval[z,1,0,t],t>n,t<n+8},t],{n,0,365,8}];



FindRoot[dervz[t]==0,{t,0,8}]

(* below works *)

t0516 = t /. DeleteCases[Table[If[Sign[dervz[n]] != Sign[dervz[n+8]],
FindRoot[dervz[t]==0,{t,n+4}], 0], {n,0,365*9.5+44,8}],0]

(* given 3 times, of zmax, zmin and next zmax, determine some angles *)

m0708[t0_,t1_,t2_] := Module[{st0, st1, stavg},

 (* first, we find the center the orbit *)

 st0 = {eval[x,1,0,t0],eval[y,1,0,t0],eval[z,1,0,t0]};
 st1 = {eval[x,1,0,t1],eval[y,1,0,t1],eval[z,1,0,t1]};
 stavg = (st0+st1)/2;

 (* now, the angle from maxz to ICRF 2000 *)

 angz = ArcTan[st0[[1]],st0[[2]]];

 (* and the inclination angle to ICRF 2000 *)

 (* adjusted st0, for vertical centering and spin by -angz *)

 st2 = rotationMatrix[z,-angz].(st0-{0,0,stavg[[3]]});

 zan = ArcTan[st2[[1]],st2[[3]]];

]

(* does this work? *)

s2[t_] := rotationMatrix[z,-angz].s[t];

s3[t_] := rotationMatrix[y,-zan].rotationMatrix[z,-angz].s[t];

Plot[{s3[t][[3]],s[t][[3]]},{t,10,999}]

(* flattening is imperfect? *)

s2[t_] := rotationMatrix[y,-zan+5*Degree].rotationMatrix[z,-angz].s[t];
s2[t_] := rotationMatrix[y,-zan+7*Degree].rotationMatrix[z,-angz].s[t];




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







