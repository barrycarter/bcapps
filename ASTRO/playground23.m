(* an approach using pos[] and piecewise *)

pos[jupiter][Rationalize[info[jstart]]]

(* need rational values for pos *)

info[jstart] = Rationalize[info[jstart]];
info[jend] = Rationalize[info[jend]];

(* the conditions for jupiter *)

conds[jupiter] = Table[t>=i && t<=i+32,{i,info[jstart],info[jend]-1,32}];

(* saturn also has 32-day polys *)

conds[saturn] = conds[jupiter];

(* and the polynomials *)

(*
polys[jupiter] = Table[
Table[chebyshev[pos[jupiter][u][[1,i]],t],{i,1,3}],
{u,Rationalize[info[jstart]],Rationalize[info[jend]],32}];
*)

polys[jupiter] = Table[
Table[chebyshev[pos[jupiter][u][[1,i]],Mod[t-info[jstart],32]/16-1],{i,1,3}],
{u,info[jstart],info[jend]-1,32}];

posxyz[jupiter,t_] = Piecewise[
Table[{polys[jupiter][[i]],conds[jupiter][[i]]},{i,1,Length[polys[jupiter]]}]];

polys[saturn] = Table[
Table[chebyshev[pos[saturn][u][[1,i]],Mod[t-info[jstart],32]/16-1],{i,1,3}],
{u,info[jstart],info[jend]-1,32}];

posxyz[saturn,t_] = Piecewise[
Table[{polys[saturn][[i]],conds[saturn][[i]]},{i,1,Length[polys[saturn]]}]];

(* for earthmoon, 32 won't work, so generalizing below *)

(*
polys[p_] := polys[p] = Table[Table[chebyshev[pos[p][u][[1,i]],
Mod[t-info[jstart],32/info[p][chunks]]/16-1],{i,1,3}],
{u,info[jstart],info[jend]-1,32/info[p][chunks]}];

foo = 
Flatten[
Table[pos[earthmoon][u][[i,j]],
{u,info[jstart],info[jend]-1,32},
{i,1,Length[pos[earthmoon][u]]},
{j,1,3}
],1];
*)

(* flatten the list of polynomials from pos? *)

conds[p_] := conds[p] = Table[t>=i && t<=i+32/info[p][chunks],
 {i,info[jstart],info[jend]-1,32/info[p][chunks]}];

polys[p_] := polys[p] = 
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








