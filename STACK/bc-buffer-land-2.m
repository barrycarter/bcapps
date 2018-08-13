(*

different and easier approach to solve 

https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

using https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ (signed version)

Mathematica surprisingly disappointed me so I wrote and ran
bc-buffer-land.pl and put the results in land-by-coast-dist.txt.bz2,
and I use that file below

*)

<formulas>

(* to stop Mathematica stupidity *)

$AllowInternet = False;

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

earthRadius = Entity["Planet", "Earth"]["Radius"]/Quantity[1,"km"];

</formulas>

(* restore Internet *)

$AllowInternet = True;

(* must determine Earth's radius w/ Internet on, grumble *)

earthRadius = Entity["Planet", "Earth"]["Radius"]/Quantity[1,"km"];

(* read NASA file *)

nasaFile = "/home/barrycarter/20180807/dist2coast.signed.txt.bz2";

(* TODO: using a fixed filename for output here is bad *)

Run["bzcat "<>nasaFile<>" > /tmp/output.txt"];

coast0 = ReadList["/tmp/output.txt", {Number, Number, Number}];

(* fixing the raw version by turning the distance into meters *)

coast = Table[{i[[1]], i[[2]], Round[i[[3]]*1000]}, {i, coast0}];

(* the area of a cell at the equator, .04 degree x .04 degree *)

maxarea = (earthRadius*2*Pi/360/25)^2

(* the amount of area for each distance *)

(* TODO: there must be a better way to do this, but Gather[] is too slow *)

Clear[f];
f[x_] = 0;

Table[f[i[[3]]] = f[i[[2]]] + maxarea*Cos[i[[2]]*Degree], {i, 
 Take[coast, 5000]}];


Table[f[i[[3]]] = f[i[[2]]] + maxarea*Cos[i[[2]]*Degree], {i, coast}];





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

using https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ (signed version)


The file *** makes this problem trivial, since it lists coastal distances both on land (given as negative numbers) and water (given as positive numbers). Brief notes:

  - 


TODO: note text file



</answer>
