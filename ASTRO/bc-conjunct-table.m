(* Uses the results of bc-pos-dump.m to find conjunction candidates *)

seps[mercury][venus] = Table[{jd,VectorAngle[
earthvector2[jd,mercury],earthvector2[jd,venus]]},
{jd,info[jstart],info[jend]}];

(* TODO: add this to lib! [not, insufficiently generic] *)

minseps[tab_] := 






(* this is JFF, in reality we will find local minima *)

sepssort[mercury][venus] = Sort[seps[mercury][venus], #1[[2]] < #2[[2]] &];


