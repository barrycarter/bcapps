(* an approach using pos[] and piecewise *)

conds[p_] := Table[t>=i && t<=i+32/info[p][chunks],
 {i,info[jstart],info[jend]-1,32/info[p][chunks]}];

polys[p_] := 
Flatten[
Table[chebyshev[pos[p][u][[i,j]],
      Mod[t-info[jstart],32/info[p][chunks]]/
      (32/info[p][chunks])*2-1],
{u,info[jstart],info[jend]-1,32},
{i,1,Length[pos[p][u]]},
{j,1,3}
],1];

posxyz[p_,t_] := posxyz[p,t] = Piecewise[
Table[{polys[p][[i]],conds[p][[i]]},{i,1,Length[polys[p]]}]];

(* need rational values for pos[] *)

info[jstart] = Rationalize[info[jstart]];
info[jend] = Rationalize[info[jend]];

posfxyz[p_] := Module[{conds,polys},

 conds = Table[t>=i && t<=i+32/info[p][chunks],
 {i,info[jstart],info[jend]-1,32/info[p][chunks]}];

Print[conds];

 polys = Flatten[Table[chebyshev[pos[p][u][[i,j]],
      Mod[t-info[jstart],32/info[p][chunks]]/(32/info[p][chunks])*2-1],
{u,info[jstart],info[jend]-1,32},{i,1,Length[pos[p][u]]},{j,1,3}],1];

 Return[Piecewise[Table[{polys[[i]],conds[[i]]},{i,1,Length[polys[p]]}]]];
]

info[jend] = info[jstart]+32*2

f = posfxyz[earthmoon]

test0838 = Piecewise[{{t^2,t<0},{t/2,t>0}}];

test0839[t_] = test0838;








