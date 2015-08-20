(* Load in mx files created by bc-dump-cheb.pl *)

DumpGet["/home/barrycarter/SPICE/KERNELS/ascp01000.431.bz2.venus,jupiter,earthmoon,sun.mx"];
DumpGet["/home/barrycarter/SPICE/KERNELS/CONJUNCTIONS/seps1000.mx"];

(* find the maximal separation of Venus/Jupiter/Regulus and then max
separation from Sun; sort to assure JD order *)

seps2=Sort[Table[{i[[1]],Max[Take[i[[2]],3]],Max[Take[i[[2]],-3]]},{i,seps}]];

(* and the actual formula *)

max[jd_] := Max[{
 VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus],
 earthangle[jd,venus,jupiter]
}];

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* find local minima *)

mins =  Table[{i,seps2[[i]]}, {i,Select[Range[2,Length[seps2]-1],
 seps2[[#,2]]<=seps2[[#+1,2]] && seps2[[#,2]]<=seps2[[#-1,2]] &]}];

(* find actual lowest instant *)

truemin[minelt_] := ternary[minelt[[2,1]]-1,minelt[[2,1]]+1,max,10^-6];



mins2=Table[ternary[i[[2,1]]-1,i[[2,1]]+1,max,10^-9],{i,mins}];

DumpSave["/home/barrycarter/SPICE/KERNELS/CONJUNCTIONS/rmin1000.mx", mins2];

(* format as degrees and days *)

fjd[jd_] := DateList[(jd-2415020.5)*86400];

mins4 = Table[{fjd[mins3[[i,1]]],Round[mins3[[i,2]]/Degree,1/1000.]}, 
 {i,1,Length[mins3]}];

mins5 = Sort[mins4, #1[[2]]  < #2[[2]] &];

mins6 = Select[mins5, #1[[2]] <= 5.5&];



mins =  Sort[Table[{maxt[[i,1]],Round[maxt[[i,2]]/Degree,.01]}, 
{i,Select[Range[2,Length[maxt]-1],
maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &]}],
#1[[2]] < #2[[2]] &];

mins =  Sort[Table[{fjd[maxt[[i,1]]],Round[maxt[[i,2]]/Degree,.01]}, 
{i,Select[Range[2,Length[maxt]-1],
maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &]}],
#1[[2]] < #2[[2]] &];

*)
