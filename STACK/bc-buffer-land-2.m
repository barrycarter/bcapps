(*

different and easier approach to solve 

https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

using https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ (signed version)

Mathematica surprisingly disappointed me so I wrote and ran
bc-buffer-land.pl and put the results in land-by-coast-dist.txt.bz2,
and I use that file below

*)

<formulas>

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

earthRadius = Entity["Planet", "Earth"]["Radius"]/Quantity[1,"km"];

</formulas>

(* this is really clever, but not actually that efficient *)

t = ReadString[
"!bzcat /home/barrycarter/BCGIT/STACK/land-by-coast-dist.txt.bz2"];

(* more efficient *)

Run["bzcat /home/barrycarter/BCGIT/STACK/land-by-coast-dist.txt.bz2 > /tmp/output.txt"];

t1258 = ReadList["/tmp/output.txt", {Number, Number, Number}];

Length[t1258] (* is 4727612 *)

t0955 = Table[{i[[1]], i[[3]]}, {i, t1258}];

ListPlot[t0955];



(* this has some inherent interest *)

t1736 = Sort[t1258, #1[[3]] < #2[[3]] &];

t1805 = Gather[t1736, #1[[3]] == #2[[3]] &];

(* to do: find number of coast line points? *)



area = (4/100/360*earthRadius*2*Pi)^2

t1717 = Table[{Cos[i[[2]]*Degree], i[[3]]}, {i, t1258}];

t1727 = Gather[t1717, #1[[2]] == #2[[2]] &];



ListPlot3D[t1258] (* times out *)

4500 points per line of longitude? (yes)

t1705 = Interpolation[t1258];

ContourPlot[t1705[lon,lat], {lon, -180, 180}, {lat, -90, 90}]

t1709 = ContourPlot[t1705[lon,lat], {lon, -180, 180}, {lat, -90, 90},
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64,  
 PlotLegends -> True, ImageSize -> {8192, 4096}]

.04 longitude times .04 latitude (= fixed)

t1722 = Gather[t1717, #1[[2]] == #2[[2]] &];

<answer>

*** PUT GRAPH HERE ***



The file *** makes this problem trivial, since it lists coastal distances both on land (given as negative numbers) and water (given as positive numbers). Brief notes:

  - 


TODO: note text file



</answer>
