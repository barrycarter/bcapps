(* Mathematica's Predict function *)

(* rand1.txt created from bc-random-1 ASTRO prog *)

a = Import["/home/user/20190602/rand1.txt", "CSV"];

b = Transpose[Take[Transpose[a], 3]];

c = Flatten[DimensionReduce[b, 1]];

d = Table[{c[[i]], a[[i,4]]}, {i, 1, Length[a]}];



hash = Table[{i[[1]], i[[2]], i[[3]]} -> i[[4]], {i, a}];

p = Predict[hash];

(* how far from its own testing data? *)

diffs = Table[p[Take[i,3]] - i[[4]], {i, a}];




test = Import["/home/user/20190602/rand2.txt", "CSV"];

(* the diffs *)

diffs = Table[p[Take[i,3]] - i[[4]], {i, test}];

(* results are WAY off *)

ContourPlot[p[{y, x, 1559498380}], {x, -180, 180}, {y, -90, 90}]

GeoGraphics[GeoRange -> { {-90, 90}, {-180, 180}}, ImageSize -> 1024]

g = GeoGraphics[GeoRange -> { {-90, 90}, {-180, 180}}]

GeoGraphics[GeoRange -> { {-90, 90}, {-180, 180}}, ImageSize -> 2048]

showit2[x_, y_] := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {x, y}]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file]; ]

(* this is METAR data in Mathematica format *)

<< /home/user/20190602/out1.txt

p2 = Predict[data];

ContourPlot[p2[{y,x,0}], {x, -180, 180}, {y, -90, 90}]
















