(* an approach using pos[] and piecewise *)

pos[jupiter][Rationalize[info[jstart]]]

(* the conditions for jupiter *)

conds[jupiter] = Table[t>=i && t<=i+32,
 {i,Rationalize[info[jstart]],Rationalize[info[jend]]-1,32}];

(* and the polynomials *)

polys[jupiter] = Table[
Table[chebyshev[pos[jupiter][u][[1,i]],t],{i,1,3}],
{u,Rationalize[info[jstart]],Rationalize[info[jend]],32}];

polys[jupiter] = Table[
Table[chebyshev[pos[jupiter][u][[1,i]],Mod[t-info[jstart],32]/16-1],{i,1,3}],
{u,Rationalize[info[jstart]],Rationalize[info[jend]]-1,32}];




