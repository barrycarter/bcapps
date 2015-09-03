(* given the trueseps and ascp file for a given millenia, put results
in final form *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

DumpGet["/home/barrycarter/SPICE/KERNELS/stars.mx"];

(* distance to a given stellar object for a list of planets *)

p2sdist[jd_,list_,star_] := p2sdist[jd,list,star] = 
Max[Table[VectorAngle[earthvector[jd,i],star[[2]]],{i,list}]]

(* given a single separation (planet list, jd, distance), clean it up *)

cleanup[list_,jd_,sep_] := Module[{sa,star},

 (* object closest to sun *)
 sa = Min[Table[earthangle[jd,i,sun],{i,list}]]/Degree;

 (* nearest stellar object *)
 star = Sort[Table[{p2sdist[jd,list,i],i[[1]]},{i,stars}]][[1]];

 Return[{jd,sep/Degree,sa,star[[2]],star[[1]]/Degree}];
];

(* annotated minseps for any list of planets *)

annminsep[list_] := annminsep[list] = 
Table[cleanup[list,i[[1]],i[[2]]], {i,trueminseps[list]}];

(* compute for all subsets *)

Table[annminsep[i],{i,conjuct1}];

outfile = "/home/barrycarter/SPICE/KERNELS/annmseps"<>"-"<>
 ToString[Round[info[jstart]]]<>"-"<>ToString[Round[info[jend]]]<>".mx";

DumpSave[outfile,{annminsep,info}];
