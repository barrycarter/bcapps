(* dumps planetary positions and will attempt to find conjunctions
using those dumped positions [I believe it will be faster to cache] *)

(* cache in general, m = memoization; hopefulyl won't run out of memory *)

posxyzm[jd_,planet_] := posxyzm[jd,planet] = posxyz[jd,planet];

earthvectorm[jd_,planet_] := earthvectorm[jd,planet] =
 posxyzm[jd,planet]-posxyzm[jd,earthmoon];

(* venus and mars as first tests *)

venus = AbsoluteTiming[
Table[{i,earthvectorm[i,venus]},{i,info[jstart],info[jstart]+3650}]
];

(* venus about 1.51s for 10 years w/o memo *)




