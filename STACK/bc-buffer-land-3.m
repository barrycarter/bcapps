(*

this is the DIY version using coastline data

*)

<formula>

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

</formula>

t1928 = Import["/home/user/20180806/coastline/GSHHS_shp/f/GSHHS_f_L1.shp",
 "Data"];

Graphics[t1928[[1,2,2]]]

(* below is just 1 poly *)

Graphics[t1928[[1,2,2,1]]]


Short[t1928[[1,2,2]],10]

179837 polys

Graphics[Apply[Line,t1928[[1,2,2]], {1}]]

Graphics[Point[Flatten[Apply[List,t1928[[1,2,2]], {1}], 2]]]

t1953 = Table[RandomReal[{-1,1}, 3], {i, 1, 10^7}];

t1954 = Table[i/Norm[i], {i, t1953}];

testpt0 = RandomReal[{-1,1}, 3]

testpt = testpt0/Norm[testpt0];

Table[testpt.i, {i,t1954}];

about 1.2s with 10M pts

562d for fine mesh plot







