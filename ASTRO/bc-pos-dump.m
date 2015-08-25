(* dumps planetary positions and will attempt to find conjunctions
using those dumped positions [I believe it will be faster to cache] *)

outfile = "/home/barrycarter/SPICE/KERNELS/daily"<>"-"<>
 ToString[Round[info[jstart]]]<>"-"<>ToString[Round[info[jend]]]<>".mx";

posxyz2[jd_,planet_] := posxyz2[jd,planet] = posxyz[jd,planet];

earthvector2[jd_,planet_] := earthvector2[jd,planet] =
 posxyz2[jd,planet]-posxyz2[jd,earthmoon];

planets={mercury,venus,mars,jupiter,saturn,uranus};

(* this returns nothing, just an excuse to evaluate earthvector2 *)

Table[earthvector2[jd,planet],{jd,info[jstart],info[jend]},{planet,planets}];

(* TODO: this should probably use info[jstart/end] to avoid overwriting *)

DumpSave[outfile,{info,earthvector2}];
