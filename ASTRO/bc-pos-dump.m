(* dumps planetary positions and will attempt to find conjunctions
using those dumped positions [I believe it will be faster to cache] *)

(* attempting to cache "retroactively" here *)

posxyz2[jd_,planet_] := posxyz2[jd,planet] = posxyz[jd,planet];

earthvector2[jd_,planet_] := earthvector2[jd,planet] =
 posxyz2[jd,planet]-posxyz2[jd,earthmoon];

planets={mercury,venus,mars,jupiter,saturn,uranus};

dailypos[p_] := dailypos[p] = 
Table[{i,earthvector2[i,p]},{i,info[jstart],info[jend]}];

Table[dailypos[p],{p,planets}];

(* TODO: this should probably use info[jstart/end] to avoid overwriting *)

DumpSave["/home/barrycarter/SPICE/KERNELS/daily2k.mx", dailypos];



