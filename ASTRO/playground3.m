(* determining orbits/etc directly from chebyshev polynomials *)

s[t_] := s[t] = {eval[x,1,0,t],eval[y,1,0,t],eval[z,1,0,t]};

(* the chebyshev interval for mercury *)

days = 8;

(* min and max days *)

{mind,maxd} = {0,365*9};

(* we will arbitrarily use successive maxs of x value to determine an orbit *)

(* TODO: can I do better? *)

derv[x,t_] := D[poly[x,1,0,t][w],w] /. w -> t;
derv[y,t_] := D[poly[y,1,0,t][w],w] /. w -> t;
derv[z,t_] := D[poly[z,1,0,t][w],w] /. w -> t;

(* the orbits *)

orbits = t /. DeleteCases[Table[If[Sign[derv[x,n]] !=
Sign[derv[x,n+8]], FindRoot[derv[x,t]==0,{t,n+4}], 0],
{n,mind,maxd,days}],0];

(* TODO: this changes each time, this is orbit1 = elts 1-3 *)

{t0,t1} = Take[orbits,{1,3,2}];

(* CUT TO MODULE HERE *)

mod[s,t0,t1]

(*

Input to module:

s - function representing position at time t
t0 - start of orbit (x=0)
t1 - end of orbit (x=0) = start of next orbit

Returns:

central point of orbit (not focus)
the angle from the equator the max value of z
the inclination
the lengths of the semimajor and semiminor axes
angle to reach maxnorm

*)

mod[s_,t0_,t1_] := Module[{rawavgs, s1, zmaxtime, angatzmax, zmaxangle,
 s2, minmaxnorm, maxnormtime, maxnormangle},

 (* averages *)

 rawavgs = Table[{NMinimize[{s[t][[i]],t>t0,t<t1},t],
                  NMaximize[{s[t][[i]],t>t0,t<t1},t]}, {i,1,3}];

 (* subtract off true averages *)

 trueavgs = Table[Mean[{rawavgs[[i,1,1]],rawavgs[[i,2,1]]}],{i,1,3}];
 s1[t_] := s[t] - trueavgs;

 (* angle of max z from ICRF equator and inclination *)

 zmaxtime = rawavgs[[3,2,2,1,2]];
 angatzmax = ArcTan[s1[zmaxtime][[1]],s1[zmaxtime][[2]]];
 zmaxangle = ArcTan[Norm[Take[s1[zmaxtime],2]], s1[zmaxtime][[3]]];

 (* ellipse flattening *)

 s2[t_] := rotationMatrix[y,-zmaxangle].rotationMatrix[z,angatzmax].s1[t];

 (* norm min and max *)

 minmaxnorm = {NMinimize[{Norm[s2[t]], t>t0, t<t1}, t], 
               NMaximize[{Norm[s2[t]], t>t0, t<t1}, t]};

 (* angle to reach max norm *)

 maxnormtime = minmaxnorm[[2,2,1,2]];
 maxnormangle = ArcTan[s2[maxnormtime][[1]], s2[maxnormtime][[2]]];

 Return[{trueavgs, angatzmax, zmaxangle, minmaxnorm[[2,1]], minmaxnorm[[1,1]],
         maxnormangle}];
];

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







