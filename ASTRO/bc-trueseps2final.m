(* given the trueseps and ascp file for a given millenia, put results
in final form *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

DumpGet["/home/barrycarter/SPICE/KERNELS/stars.mx"];

j2d[jd_] := j2d[jd] = Module[{},
 Run["j2d "<>ToString[AccountingForm[jd,Infinity]]<>" >/tmp/jdout.txt"];
 Return[ReadList["/tmp/jdout.txt","String"]];
];

(* distance to a given stellar object for a list of planets *)

p2sdist[jd_,list_,star_] := 
Max[Table[VectorAngle[earthvector[jd,i],star[[2]]],{i,list}]]

(* given a single separation (planet list, jd, distance), clean it up *)

cleanup[list_,jd_,sep_] := Module[{sa,star},

 (* object closest to sun *)
 sa = Min[Table[earthangle[jd,i,sun],{i,list}]]/Degree;

 (* nearest stellar object *)
 star = Sort[Table[{p2sdist[jd,list,i],i[[1]]},{i,stars}]][[1]];

 Return[{j2d[jd],sep/Degree,sa,star[[2]],star[[1]]/Degree}];
];


(* table of seps for merc/ven test *)

test1223 =
Table[{{mercury,venus},i[[1]],i[[2]]},{i,trueminseps[{mercury,venus}]}];

Apply[cleanup,test1223[[7]]]

test1230 = Table[Apply[cleanup,i],{i,test1223}];

