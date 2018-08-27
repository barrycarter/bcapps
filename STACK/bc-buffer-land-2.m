(*

different and easier approach to solve 

https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

using https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ (signed version)

Mathematica surprisingly disappointed me so I wrote and ran
bc-buffer-land.pl and put the results in land-by-coast-dist.txt.bz2,
and I use that file below

*)

(* 

data notes:

-2509.97 = given to two digits for min to ...

-999.999 = three digits to ...

-99.9998 = four digits to ...

-9.99994 = five digits to ...

-0.999988 = six digits to ...

-0.0999988 = seven digits to ...

-0.00998305 = eight digits to ...

-0.000997388 = nine digits to end

*)

<formulas>

(* to stop Mathematica stupidity *)

$AllowInternet = False;
$AllowInternet = True;

earthRadius = Entity["Planet", "Earth"]["Radius"]/Quantity[1,"km"];

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

</formulas>

(* we now need to create a legend(ary) legend *)

t2019 = DeleteDuplicates[Table[distance2Color[x], {x,-2000,2000}]];

SwatchLegend[Map[RGBColor, t2019], Automatic]

Plot[Norm[distance2Color[x]], {x, 0, 2000}]

t2039 = Table[{
 ToString[100*i]<>"-"<>ToString[100*(i+1)]<>" km", 
 RGBColor[distance2Color[50+100*i]]}, {i, 0, 16}]

t2039[[-1,1]] = "1600+ km";


Apply[SwatchLegend, Reverse[Transpose[t2039]], LegendMarkerSize -> 50]



(* read NASA file *)

nasaFile = "/home/barrycarter/20180807/dist2coast.signed.txt.bz2";

(* TODO: using a fixed filename for output here is bad *)

Run["bzcat "<>nasaFile<>" > /tmp/output.txt"];

coast0 = ReadList["/tmp/output.txt", {Number, Number, Number}];

(* rounding distance to nearest 10m because least precise data is that
precise, except when close to 0, to preserve sign *)

round2[x_] = If[Round[x,0.01] == 0, Sign[x]*0.01, Round[x,0.01]];

(* special case small neg/pos; using precise numbers slows Mathematica
down so the "0.01" above is intentionally not 1/100 *)

coast = Table[{i[[1]], i[[2]], round2[i[[3]]]}, {i, coast0}];

(* colordata automatically truncates! *)

landfunc = ColorData["SandyTerrain"]
waterfunc = ColorData["DeepSeaColors"]

(* this also removes the RGB header that Raster can't handle *)

Clear[distance2Color];
distance2Color[d_] := distance2Color[d] = 
Apply[List, If[d>0, waterfunc[1-Floor[d/1600,1/16]],
 landfunc[1-Floor[-d/1600,1/16]]]];

coastDists = Transpose[coast][[3]];

coastColors = Map[distance2Color, coastDists];

coastColorsArray = Partition[coastColors, 9000];

(* the above take a while, so I'm saving the result in an mx file,
even though this is a bad idea overall; the result is only about 80M! 
*)

DumpSave["/home/user/20180807/coastcolorsarray2.mx", coastColorsArray];

(* give a 2D array, "shrink" it by taking only every nth elt in both dims *)

shrink[t_, n_] := Table[t[[i,j]], {i, 1, Length[t], n}, {j, 1,
Length[t[[i]]], n}];

t1145 = shrink[coastColorsArray , 10];

Graphics[Raster[Reverse[t1145]], ColorFunction -> RGBColor,
PlotRangePadding -> 0, ImagePadding -> 0]

t1218 = Graphics[Raster[Reverse[coastColorsArray], ColorFunction -> RGBColor],
 PlotRangePadding -> 0, ImagePadding -> 0];

Export["/home/user/20180807/map3.png", t1218, ImageSize -> {9000,4500}]

tODO: can compute area using elliptical earth

(* the not-so-great circle at a given latitude, allowing for cosine and Earth's radius *)

circle[lat_] = rad[lat]*Cos[lat]

(* and the area of a 0.04 square *)

area[clat_] = Integrate[circle[lat], {lat, clat-0.02, clat+0.02}]*0.04/360

(* below per wikipedia *)

cdist[a_, b_, lat_] = Sqrt[((a*a*Cos[lat])^2 + (b*b*Sin[lat])^2) /
((a*Cos[lat])^2 + (b*Sin[lat])^2)];

(* the area of the infentesimal is 2*Pi*r in length and the height is ...

1 radian = r, so dtheta is r *)

t1337[a_, b_, lat_] = Integrate[(cdist[a,b,lat])^2*Cos[lat], lat];

t1337[6378.137, 6356.7523, 0.02*Degree] - 
 t1337[6378.137, 6356.7523, -0.02*Degree]

cdist[6378.137, 6356.7523, 1*Degree]

area[lat_] := Integrate[cdist[6378.137, 6356.7523, x]*Cos[x], {x,
lat-.02*Degree, lat+.02*Degree}]











cdist[6378.137, 6356.7523, lat]

Plot[cdist[6378.137, 6356.7523, lat*Degree], {lat, -90, 90}]

cdistint[lat_] = Integrate[cdist[a, b, lat]*Cos[lat]]

cdistint[lat_] = Integrate[cdist[6378.137, 6356.7523, lat]*Cos[lat], lat]





<< "/home/user/20180807/coastcolorsarray.mx";

Length[coastColorsArray]; (* confirms I got it *)

(*


(* ignore below

shrink[t_, n_] := Table[{i,j}, {i, 1, Length[t], n}, {j, 1,
Length[t[[i]]], n}];

*)

Table[{i,j}, {i, 1, 10, 2}, {j, 1, 10, 2}]

t1149[t_] := Table[{i,j}, {i, 1, Length[t], 2}, {j, 1, Length[t[[i]]], 2}]

t1150[t_] := Table[t[[i,j]], {i, 1, Length[t], 2}, {j, 1, Length[t[[i]]], 2}]

t1152[t_, n_] := Table[t[[i,j]], {i, 1, Length[t], n}, 
 {j, 1, Length[t[[i]]], n}]




t1146 = Table[Prime[i]+Prime[j], {i, 1, 100}, {j, 1, 100}];





t1133 = Graphics[Raster[Reverse[coastColorsArray], ColorFunction ->
RGBColor, ImagePadding -> 0]]

Export["/home/user/20180807/map2.png", t1133, ImageSize -> {9000,4500}]

(* lets get a raster to plot w/ no boundaries *)

t0953 = Table[If[i==1 || i==600 || j==1 || j==800, {1,0,0}, RandomReal[1,3]], 
 {i, 1, 600}, {j, 1, 800}];

t0954 = Graphics[Raster[t0953], PlotRangePadding -> 0];

(* above still has one line padding, grumble *)

Export["/tmp/nopad.gif", t0954, ImageSize -> {801,601}]

Run["display -update 1 /tmp/nopad.gif &"];

(* demonstrating problem below *)

t1024 = Table[If[i==1 || i==50 || j==1 || j==50, {1,0,0}, RandomReal[1,3]], 
 {i, 1, 50}, {j, 1, 50}];

t1025 = Graphics[Raster[t1024], PlotRangePadding -> 0];

Export["/tmp/nopad.gif", t1025, ImageSize -> {50,50}]

Run["display -update 1 /tmp/nopad.gif &"];

Subject: `PlotRangePadding -> 0` still leaves 1 pixel border

The following should create a 50x50 image named `/tmp/nopad.gif` with mostly random colors and a red border:

<pre><code>
t1024 = Table[If[i==1 || i==50 || j==1 || j==50, {1,0,0}, RandomReal[1,3]], 
 {i, 1, 50}, {j, 1, 50}];
t1025 = Graphics[Raster[t1024], PlotRangePadding -> 0, ImagePadding -> 0];
Export["/tmp/nopad.gif", t1025, ImageSize -> {50,50}]
</code></pre>

Here's the image: [[/tmp/nopad.gif]]

It's hard to tell directly, but if you load the image into ImageMagick's display and use the magnify feature, you'll see a one pixel white border at the right and bottom edges:

[[/tmp/pad.png]]

Note that display counts starting at 0, so the highlighted white pixel is the 50th pixel in both the x and y directions.

As nearly as I can tell, setting `ImageSize -> {51,51}` and then trimming the result is a workaround, but is there a better way to get rid of this border?

As a note, I realize I could've just loaded the image back into Mathematica to confirm it has a border, but, hopefully, the above is convincing enough.














(* hesitant about using a function here, plus this is the wrong thing
to do for Interpolation *)

Table[distCoast[i[[1]],i[[2]]] = i[[3]], {i, coast0}];

(* there are better ways to do this, since I know the grid, but... *)

lats = Sort[DeleteDuplicates[Transpose[coast0][[2]]]];
lons = Sort[DeleteDuplicates[Transpose[coast0][[1]]]];
dists = Sort[DeleteDuplicates[Transpose[coast0][[3]]]];

ContourPlot[x, {x,0,1},{y,0,1}, ColorFunction -> Hue, Contours -> 31,
ContourLabels -> True]

0 - .434 = 14/32 seems good for land (but keep green inland)

.465 - .713 seems good for water (green closest to land) 15/32 to 23/32

Graphics[Raster[Table[{i,j}, {j,0,16}, {i, 0, 14/32, 14/32/16}], 
 ColorFunction -> Hue]]

ContourPlot[x, {x,0,1},{y,0,1}, ColorFunction ->
ColorData["CoffeeTones"], Contours -> 15, ContourLabels -> True]

ContourPlot[x, {x,0,1},{y,0,1}, ColorFunction ->
ColorData["SandyTerrain"], Contours -> 15, ContourLabels -> True]

ContourPlot[x, {x,0,1},{y,0,1}, ColorFunction ->
ColorData["DeepSeaColors"], Contours -> 15, ContourLabels -> True]

ContourPlot[x, {x,0,1},{y,0,1}, ColorFunction ->
ColorData["GreenBrownTerrain"], Contours -> 15, ContourLabels -> True]

Table[landfunc[i], {i, 0, 1, 1/10}, {j, 0, 10}]

raster can't take pure colors grrr

Table[Apply[List, landfunc[i]], {i, 0, 1, 1/10}, {j, 0, 10}]

Raster[Table[Apply[List, landfunc[i]], {i, 0, 1, 1/10}, {j, 0, 10}],
 ColorFunction -> RGBColor]

t1258 = Table[
 Apply[distance2Color[distCoast[lon, lat]], List], 
 {lon, Take[lons,500]}, {lat, Take[lats,500]}
]
t1258 = Table[
 Apply[List, distance2Color[distCoast[lon, lat]]],
 {lon, Take[lons,500]}, {lat, Take[lats,500]}
]

t1258 = Table[
 Apply[List, distance2Color[distCoast[lon, lat]]],
 {lon, lons}, {lat, Take[lats,500]}
];

t1258 = Table[
 Apply[List, distance2Color[distCoast[lon, lat]]],
 {lon, Take[lons,500]}, {lat, Take[lats,500]}
];

t1258 = Table[
 Apply[List, distance2Color[distCoast[lon, lat]]],
 {lon, lons}, {lat, Take[lats,500]}
];

t1258 = Table[
 Apply[List, distance2Color[distCoast[lon, lat]]],
 {lon, lons}, {lat, lats}
];

Graphics[Raster[t1258]]
showit









(*  different values, 509997 when rounded to nearest 10m, 509996 once I get rid of the 0's *)

(* there were 1031 0s per Select[coast, #[[3]] == 0 &] *)

dists = DeleteDuplicates[Sort[Transpose[coast][[3]]]];

(* TODO: maybe dist vs number of points, though irrelevant *)

(* TODO: level 4 data incl ponds on islands in seas *)

(* the area of a cell at the equator, .04 degree x .04 degree *)

maxarea = (earthRadius*2*Pi/360/25)^2

(* the amount of area for each distance *)

(* Gather was too slow when I didn't round should be ok now *)

pointsByDist = Gather[coast, #1[[3]] == #2[[3]] &];

(* create a function to make things easier (?) *)

(* Table[dist2Points[i[[1,3]]] = i  *)

distTotal = Sort[Table[{i[[1,3]], 
 maxarea*Total[Map[Cos[#*Degree] &, Transpose[i][[2]]]]},
 {i, pointsByDist}], #1[[1]] < #2[[1]] &];

ListPlot[distTotal, PlotRange -> All, PlotJoined -> True]




(* TODO: there must be a better way to do this, but Gather[] is too slow *)

Clear[f];
f[x_] = 0;
Table[f[i[[3]]] = f[i[[3]]] + maxarea*Cos[i[[2]]*Degree], {i, coast}];

ListPlot[Table[{i, f[i]}, {i, dists}], PlotJoined -> True];

TODO: discretize

TODO: use the word "discretize" as much as possible

100km hue plot

hue[x_] = Round[If[x>0, Min[0.7,0.5 + 0.2/1600*x], Max[0.2+0.2/1600*x, 0]],
 .2/16]

Plot[hue[x],{x,-2000,2000}]

t1330 = Reverse[Partition[Transpose[coast][[3]], 9000]];

t1331 = Map[hue, t1330, {2}];

t1332 = Raster[t1331, ColorFunction -> Hue];

Graphics[t1332]



testing...


t1348 = Raster[Take[t1331,500], ColorFunction -> Hue];

Graphics[t1348]


















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

why de[ck]ameter

using https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ (signed version)


The file *** makes this problem trivial, since it lists coastal distances both on land (given as negative numbers) and water (given as positive numbers). Brief notes:

  - 


TODO: note text file

rounded to nearest kn

two other approaches: GeoDistance and 3D projection

points only not vectors

tides and coastline paradox

see bc-buffer-land.m for other version

also solve the antipode problem

compare to known total area and known water/land area

note spherical

color kode and key [prob 25km/color for 64 colors and top out]

</answer>
