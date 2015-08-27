(* Uses the results of bc-pos-dump.m to find conjunction candidates *)

outfile = "/home/barrycarter/SPICE/KERNELS/mseps"<>"-"<>
 ToString[Round[info[jstart]]]<>"-"<>ToString[Round[info[jend]]]<>".mx";

planets={mercury,venus,mars,jupiter,saturn,uranus};

(* sets of at least two planets *)

conjuct1 = Subsets[planets,{2,Length[planets]}];

(* Given a commutative function and a list, find the maximum of the
function when applied pairwise to members of the list *)

maxflist[f_,list_] := Max[Table[Apply[f,x],
 {x,Flatten[Table[{list[[i]],list[[j]]}, 
 {i,1,Length[list]-1},{j,i+1,Length[list]}],1]}]];

(* angular separation as viewed from Earth, two planets *)

angsep[p1_,p2_] := VectorAngle[earthvector2[jd,p1],earthvector2[jd,p2]];

(* Given a table of separations, find local minima, sorted *)

minseps[tab_] := Sort[Table[{i,tab[[i]]}, {i,Select[Range[2,Length[tab]-1], 
tab[[#,2]] <= Min[tab[[#-1,2]],tab[[#+1,2]]] &]}],#1[[2,2]] < #2[[2,2]] &];

minseps[tab_] := Table[tab[[i]], {i,Select[Range[2,Length[tab]-1], 
tab[[#,2]] <= Min[tab[[#-1,2]],tab[[#+1,2]]] &]}];

(* minimum separations for given list of planets *)

(****** TODO: 7 is just a test below !!! ****)

minangdists[list_] := minangdists[list] = Module[{t},

 (* the daily separations *)
 t = Table[{jd,maxflist[angsep,list]},{jd,info[jstart],info[jstart]+7777}];

 (* local minima and the list sent in*)
 Return[minseps[t]];
];

(* and run that for all of them *)

Table[minangdists[i],{i,conjuct1}];

(* TODO: restore below *)

DumpSave[outfile,{minangdists,info}];

