(*** abandoned ***)

(* attempts to go directly from ascp*.mx files to minimal separations;
this means I am doing repeat work (since Ive already created
intermediate files, but might be easier to understand and cleaner *)

(* TODO: this may run out of memory (which is maybe why I broke it
into steps in the first place? *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

earthvector2[jd_,planet_] := earthvector2[jd,planet] = 
 posxyz[jd, planet] - posxyz[jd, earthmoon];

(* this table just evaluates earthvector2 *)

Table[earthvector2[jd,planet],{jd,info[jstart],info[jend]},{planet,planets}];


