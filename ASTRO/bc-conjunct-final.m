(* Given the mseps*.mx files created by bc-conjuct-table.m and the
correct asc[pm]* file, find the instants of best conjunction, filter
to conjunctions with 6 degrees [or whatever], compute solar angle and
compute nearest fixed object *)

(* Sample of what mseps*.mx defines: minangdists[{mercury,venus,mars}][[7]] *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

(* TODO: looking only at seps less than 8 degrees to find mins less
than 6 degrees might be invalid here, especially for {venus,mars} *)

minangdists2[list_] := minangdists2[list] = 
 Select[minangdists[list], #[[2]] < 8*Degree&];

(* eval for all *)

Table[minangdists2[list],{list,conjuct1}];

(* max separation of list at given instant *)

maxseplist[jd_,list_] := maxseplist[jd,list] = Max[Table[
 VectorAngle[earthvector[jd,list[[i]]],earthvector[jd,list[[j]]]],
{i,1,Length[list]-1},{j,i+1,Length[list]}]];

(* given a date and a list, find the min separation from date-1 to date+1 *)

trueminsep[jd_,list_] := trueminsep[jd,list] = Module[{f},

 (* define the unary function that is the max separation *)
 f[x_] := maxseplist[x,list];

 Return[ternary[jd-1,jd+1,f,1/86400]];
]

(* thread for every separation in given list *)

trueminseps[list_] := trueminseps[list] = 
Select[Table[trueminsep[jd,list],
 {jd,Transpose[minangdists2[list]][[1]]}], #[[2]] < 6*Degree &];

(* compute them all *)

Table[trueminseps[i],{i,conjuct1}];

outfile = "/home/barrycarter/SPICE/KERNELS/truemseps"<>"-"<>
 ToString[Round[info[jstart]]]<>"-"<>ToString[Round[info[jend]]]<>".mx";

DumpSave[outfile,{trueminseps,info}];









