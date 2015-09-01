(* graphing conjunctions JFF *)

(* for 1000 and 100 years, this method isn't even close *)

delta = 365*25;

AbsoluteTiming[xyz = Table[
Plot[earthangle[jd,mercury,venus],{jd,i,i+delta}],
{i,info[jstart],info[jend],delta}]
];

(* Timing for delta:

100 years: 19 seconds
25 years:  71 seconds
10 years: 156 seconds
 5 years: 255 seconds
 3 years: 350 seconds
 1 year: 618 seconds
*)

points = Flatten[Table[i[[1,1,3,2,1]],{i,xyz}],1];

(* Number of points sampled (365280 days)

100 years: 31367
25 years: 120139
10 years: 258813
 5 years: 425461
 3 years: 584498
 1 year: 1031693

*)

minin = Select[Range[2,Length[points]-1], 
points[[#,2]] < points[[#+1,2]] && points[[#,2]] < points[[#-1,2]] &];

f = Function[t,earthangle[t,mercury,venus]];

test1828 = Table[ternary[points[[i-1,1]],points[[i+1,1]],f,1/48],
{i,minin}];



Plot[f[t],{t,points[[42,1]],points[[44,1]]}]

minpts = Table[points[[i]],{i,minin}];

min2 = Select[minpts, #[[2]]<6*Degree&];

(* Number of conjunctions found (daily finds 2335):

100 years: 1583
10 years: 2327
 5 years: 2335
 3 years: 2337
 1 year: 2337
*)

true = trueminseps[{mercury,venus}];

diffs = Table[min2[[i]]-true[[i]],{i,1,
Min[Length[min2],Length[true]]}]

Abs[Transpose[diffs][[1]]]

Max[
 AbsoluteValue[Transpose[Table[min2[[i]]-true[[i]],{i,1,Length[min2]}]][[1]]]
]

(* below to track down problem of psuedo-min? *)

Plot[earthangle[jd,mercury,venus],{jd,true[[1,1]],min2[[1,1]]}]

FindMinimum[earthangle[jd,mercury,venus],{jd,info[jstart]}

NMinimize[{earthangle[jd,mercury,venus],jd>info[jstart]},jd,
 Method->RandomSearch]

FindMinimum[{earthangle[jd,mercury,venus],jd>info[jstart]&&jd<info[jend]}, 
{jd,min2[[1,1]]},
Method -> LinearProgramming]


Plot[earthangle[jd,mercury,venus],{jd,2.4557906206687754`*^6,
2.455878831384927`*^6+5}]

Plot[earthangle[jd,mercury,venus],{jd,2.4557906206687754`*^6+22,
2.455878831384927`*^6+5}]

(* function of one variable *)

f[t_Real] := Module[{},
Print["CALLED: ",t];
Return[earthangle[t,mercury,venus]];
];

min=FindMinimum[{f[t],t>info[jstart]},{t,info[jstart]}]
max=FindMaximum[{f[t],t>2.4515365`*^6},{t,2.4515365`*^6}]

min=FindMinimum[{f[t],t>info[jstart]+365},{t,info[jstart]+365}]



(* Largest misses

10 years: NA, doesn't get all
 5 years: generally within .3 days, .1 degree
 3 years: can't compute, mismatch in number

*)

delta = .001;

Plot[
 (earthangle[jd+delta,mercury,venus]-
 earthangle[jd-delta,mercury,venus])
 /2/delta,
{jd,info[jstart],info[jstart]+365*10}];













(* an attempt to inline a function so Mathematica treats it as a pure
function *)

posxyz[jd_,planet_] := Module[{jd2,chunk,days,t},

   (* which chunk *)
   chunk = Floor[Mod[(jd-33/2),32]/(32/info[planet][(Floor[Mod[(jd-33/2),32]/(32/info[planet][chunks])]+1)s])]+1;

   (* where in chunk *)
   t = Mod[(jd-33/2),(32/info[planet][(Floor[Mod[(jd-33/2),32]/(32/info[planet][chunks])]+1)s])]/(32/info[planet][chunks])*2-1;

   (* and Chebyshev *)
   Table[chebyshev[pos[planet][Quotient[(jd-33/2),32]*32+33/2][[chunk]][[i]],t],
    {i,1,3}]
];



(* an approach using pos[] and piecewise *)

(* need rational values for pos[] *)

info[jstart] = Rationalize[info[jstart]];
info[jend] = Rationalize[info[jend]];

posfxyz[p_] := Module[{conds,polys},

 conds = Table[t>=i && t<=i+32/info[p][chunks],
 {i,info[jstart],info[jend]-1,32/info[p][chunks]}];

 polys = N[
Flatten[Table[chebyshev[pos[p][u][[i,j]],
      Mod[t-info[jstart],32/info[p][chunks]]/(32/info[p][chunks])*2-1],
{u,info[jstart],info[jend]-1,32},{i,1,Length[pos[p][u]]},{j,1,3}],1]
];

 Return[Piecewise[Table[{polys[[i]],conds[[i]]},{i,1,Length[polys]}]]];
]

f[t_] = posfxyz[earthmoon];

test[t_] = f;





(******* TESTS START HERE ********)





info[jend] = info[jstart]+32*2

f = posfxyz[earthmoon]

test0838 = Piecewise[{{t^2,t<0},{t/2,t>0}}];

test0839[t_] = test0838;








