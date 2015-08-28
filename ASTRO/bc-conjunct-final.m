(* Given the mseps*.mx files created by bc-conjuct-table.m and the
correct asc[pm]* file, find the instants of best conjunction, filter
to conjunctions with 6 degrees [or whatever], compute solar angle and
compute nearest fixed object *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

maxflist[f_,list_] := Max[Table[Apply[f,x],
 {x,Flatten[Table[{list[[i]],list[[j]]}, 
 {i,1,Length[list]-1},{j,i+1,Length[list]}],1]}]];

(* TODO: angsep should be a function of jd in bc-conjuct-table.m too *)

angsep[p1_,p2_,jd_] := VectorAngle[earthvector2[jd,p1],earthvector2[jd,p2]];


