(* graphing conjunctions JFF *)

p = Plot[earthangle[jd,mercury,venus],{jd,info[jstart],info[jend]}];

points = p[[1,1,3,2,1]];

minin = Select[Range[2,Length[points]-1], 
points[[#,2]] < points[[#+1,2]] && points[[#,2]] < points[[#-1,2]] &];

minpts = Table[points[[i]],{i,minin}];

min2 = Select[minpts, #[[2]]<6*Degree&];

(* finds 260 conjunctions *)

true = trueminseps[{mercury,venus}];

(* 2.4516196051509483*10^6 is first true conjunction, plot misses it *)




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








