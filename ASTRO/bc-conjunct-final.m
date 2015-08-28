(* another approach using functions directly *)

test0722[jd_] := VectorAngle[earthvector[jd,mercury], earthvector[jd,venus]];

Plot[test0722[jd],{jd,info[jstart],info[jstart]+365}];

Plot[earthvector[jd,mercury][[1]],{jd,info[jstart],info[jstart]+365}]
Plot[earthvector[jd,mercury][[2]],{jd,info[jstart],info[jstart]+365}]
Plot[earthvector[jd,mercury][[3]],{jd,info[jstart],info[jstart]+365}]

Plot[earthvector[jd,venus][[1]],{jd,info[jstart],info[jstart]+365}]
Plot[earthvector[jd,venus][[2]],{jd,info[jstart],info[jstart]+365}]
Plot[earthvector[jd,venus][[3]],{jd,info[jstart],info[jstart]+365}]

Table[VectorAngle[earthvector[jd,mercury],earthvector[jd,venus]],
{jd,info[jstart],info[jstart]+365,.01}];

Trace[Plot[VectorAngle[earthvector[jd,mercury], earthvector[jd,venus]],
{jd,info[jstart],info[jstart]+365}]] >> /tmp/math.txt










(* Given the mseps*.mx files created by bc-conjuct-table.m and the
correct asc[pm]* file, find the instants of best conjunction, filter
to conjunctions with 6 degrees [or whatever], compute solar angle and
compute nearest fixed object *)

planets={mercury,venus,mars,jupiter,saturn,uranus};
conjuct1 = Subsets[planets,{2,Length[planets]}];

(* max separation of list at given instant *)

maxseplist[jd_,list_] := maxseplist[jd,list] = Max[Table[
 VectorAngle[earthvector[jd,list[[i]]],earthvector[jd,list[[j]]]],
{i,1,Length[list]-1},{j,i+1,Length[list]}]];

(* given a date and a list, find the min separation from date-1 to date+1 *)

trueminsep[jd_,list_] := trueminsep[jd,list] = Module[{f},

 Print[jd,list];

 (* define the unaryfunction that is the max separation *)
 f[x_] := maxseplist[x,list];

 Return[ternary[jd-1,jd+1,f,1/86400]];
]

(* thread for every separation in given list *)

trueminseps[list_] := trueminseps[list] = Table[trueminsep[jd,list],
 {jd,Transpose[minangdists[list]][[1]]}];

(* can I use an interpolating function to find mins easier? *)

test0605 = FunctionInterpolation[maxseplist[jd,{mercury,venus,mars}],
 {jd,info[jstart],info[jstart]+365*10}];

Plot[{test0605[jd],maxseplist[jd,{mercury,venus,mars}]},
{jd,info[jstart],info[jstart]+365*10}]

Plot[{test0605[jd]-maxseplist[jd,{mercury,venus,mars}]},
{jd,info[jstart],info[jstart]+365*10},PlotRange->All]

test0705 = FunctionInterpolation[maxseplist[jd,{mercury,venus}],
 {jd,info[jstart],info[jstart]+365*10}];

Plot[{test0705[t]-maxseplist[t,{mercury,venus}]},
 {t,info[jstart],info[jstart]+365*10},PlotRange->All]

test0707 = FunctionInterpolation[maxseplist[jd,{mercury,venus}],
 {jd,info[jstart],info[jstart]+365*10},InterpolationOrder->10];

Plot[{test0707[t]-maxseplist[t,{mercury,venus}]},
 {t,info[jstart],info[jstart]+365*10},PlotRange->All]














