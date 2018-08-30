(*

https://www.reddit.com/r/geography/comments/8qzl3p/if_we_redrew_us_state_lines_by_voronoi_of_the_top/

*)

<oneoff>

(* run these commands first to build caches *)

metrosAll = EntityList["MetropolitanArea"];

tab = Table[{i, i["Name"], i["Population"], i["Position"], i["Country"]},
 {i, metrosAll}]

tab >> ~/BCGIT/REDDIT/metro-area-data.m

</oneoff>

<formulas>

(* Mathematica is being cocksucky w/ forced updates *)

$AllowInternet = False;
$AllowInternet = True;

(* find US metro areas *)

metrosAll = << ~/BCGIT/REDDIT/metro-area-data.m;

metrosUSA = Select[metrosAll, 
 #[[5]] == Entity["Country", "UnitedStates"]&];

(* top 50 by pop *)

metrosUSASorted = Sort[metrosUSA, #1[[3]] > #2[[3]] &]

metrosUSATop = Take[metrosUSASorted, 50];

(* form usable to Mathematica *)

(* geopos = Table[i[[4]] -> i, {i, metrosUSATop}]; *)

(* geopos = Table[GeoPositionXYZ[i[[4]]][[1]] -> i, {i, metrosUSATop}]; *)

(* geopos = Table[ GeoPositionXYZ[metrosUSATop[[i,4]]][[1]] -> i,
 {i, 1, Length[metrosUSATop]}] *)

(* lonLatDeg2XYZ[lon_, lat_] := GeoPositionXYZ[GeoPosition[{lat, lon}]][[1]]; *)

lonLatDeg2XYZ[lon_, lat_] = sph2xyz[lon*Degree, lat*Degree, 1];

lonLatDeg2XYZ[l_] := lonLatDeg2XYZ @@ l;

(* MUST USE "Reverse" if doing lonLatDeg2XYZ *)

geopos = Table[lonLatDeg2XYZ[Reverse[metrosUSATop[[i,4,1]]]], {i,
1,Length[metrosUSATop]}];

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

(* closestMetroTab = Table[{i, Nearest[geopos, i[[4]]]}, {i, metrosUSASorted}]; *)

rectifyCoords[list_] := Transpose[Reverse[Transpose[list]]];

(* this is just for printing *)

(* printTab = Table[{i[[1,2]], i[[2,1,2]]}, {i, closestMetroTab}] *)

(* closestMetros = Gather[closestMetroTab, #1[[2]] == #2[[2]] &]; *)

Print["Using spherical, NOT ELLIPTICAL, coordinates"];

</formulas>

(* returning to nearest region approach *)

regNear = RegionNearest[Point[geopos]];

nearest[lon_, lat_] := Position[geopos, 
 regNear[lonLatDeg2XYZ[lon,lat]]][[1,1]];

Timing[Table[nearest[lon, lat], {lon, -130, -60, 0.1}, {lat, 25, 50, 0.1}]];

3.95 sec to do 700 by 250

t1805 = Timing[
 Table[nearest[lon, lat], {lon, -125, -66, 0.02}, {lat, 24, 50, 0.02}]
];

t1806 = t1805[[2]];

15.1851 sec to do 1400 by 500

to do 2950 by 1300, it takes... 83.14 seconds

US extrema: n 50, s 24, e -66, w -125

rc = Table[RandomReal[1,3], {i,1,50}];

t1807 = Map[rc[[#]] &, t1806, {2}];

t1808 = Transpose[t1807];

t1809 = Graphics[Raster[t1808], ImagePadding -> 0, PlotRangePadding -> 0];

Export["/tmp/voronoi.png", t1809, ImageSize -> {2951, 1301}];

http://test.bcinfo3.barrycarter.info/bc-image-overlay-nokml.pl?e=-66&w=-125&n=50&s=24&center=37,-95.5&url=metrovor.png&zoom=4

(* placemarks *)

(* TODO: could I use Mathematica's built in KML support here? *)

placemark[i_] := {i[[2]], i[[3,1]], Reverse[i[[4,1]]]};

template = "
<Placemark>
<name>`name`</name>
<description>`description`</description>
<Point><coordinates>`lon`,`lat`,0</coordinates></Point>
</Placemark>
";

placemark[i_] := StringTemplate[template][<|
 "name" -> i[[2]], "description" -> "Population: "<>ToString[i[[3,1]]], 
 "lon" -> i[[4,1,2]], "lat" -> i[[4,1,1]]
|>];

placemarks = Table[placemark[i], {i, metrosUSATop}];

Export["/tmp/pmarks.txt", StringJoin[placemarks]];

(* TODO: make placemarks match underlying color? *)


placemark[metrosUSATop[[6]]]

[<|"a" -> 1234, "b" -> 5678|>]


placemark[i_] := "<Placemark>\n<name>\n"<>i[[2]]<>"\n</name>\n</Placemark>";





(* Cut the rectangle from {lon1, lat1} to {lon2, lat2} into 4 smaller
rectangles -- works ok actually, a little slow *)

rect24Rects[lon1_, lat1_, lon2_, lat2_] = {
 {lon1, lat1, (lon1+lon2)/2, (lat1+lat2)/2},
 {(lon1+lon2)/2, lat1, lon2, (lat1+lat2)/2},
 {lon1, (lat1+lat2)/2, (lon1+lon2)/2, lat2},
 {(lon1+lon2)/2, (lat1+lat2)/2, lon2, lat2}
};

(* the recursive approach w/ regionnearest ... *)

(* t = tolerance TODO: make this in km or something *)

findRegions[lon1_, lat1_, lon2_, lat2_, t_] := Module[{p1, p2, p3, p4},
  p1 = nearest[lon1,lat1];
  p2 = nearest[lon2,lat1];
  p3 = nearest[lon2,lat2];
  p4 = nearest[lon1,lat2];
  If[p1 == p2 == p3 == p4, Return[{lon1, lat1, lon2, lat2, p1}]];
  If[Abs[lon1-lon2] < t && Abs[lat1-lat2] < t, 
    Return[{lon1, lat1, lon2, lat2, 0}]];
  Return[Flatten[
 Table[Apply[findRegions, Flatten[{i,t}]], 
        {i, rect24Rects[lon1, lat1, lon2, lat2]}]]];
];

findRegions[-106, 35, -105, 36]

(* overly deep nesting, fixing *)

t1822 = N[findRegions[-107, 35, -105, 36]]

(* the fact that I have to partition the result into 5 element lengths
is stupid, but let's go w/ it for now *)

t1830 = N[findRegions[-120, 25, -70, 49, 0.1]];

t1831 = Partition[t1830, 5];

rc = Table[RandomReal[1,3], {i,1,50}];

t1832 = Table[{
 If[i[[5]]==0, RGBColor[{0,0,0}], RGBColor[rc[[i[[5]]]]]], 
  Rectangle[{i[[1]], i[[2]]}, {i[[3]], i[[4]]}]}, {i, t1831}];

t1844 = N[findRegions[-120, 25, -70, 49, 0.1]];

t1845 = Partition[t1844, 5];

t1846 = Table[{
 If[i[[5]]==0, RGBColor[{0,0,0}], RGBColor[rc[[i[[5]]]]]], 
  Rectangle[{i[[1]], i[[2]]}, {i[[3]], i[[4]]}]}, {i, t1845}];

(* below fails: return can't return 3 args *)
testM := Module[{}, Return[1,2,3]];




Region`Mesh`MeshMemberCellIndex[mr, pt]



(*

Given a geographic point {lon, lat} and a set of geographic points S
in the same format (note lon precedes lat here), return the following:

  - the index of the point in S closest to P

  - the distance from S to P (in km, no units in return value)

  - the distance from P to the second closest point in S (ie, is P
  almost equidistance from two members of S) (in km, no units in return value)

*)

ps2nearestPointInS[lon_, lat_, s_] := Module[{dists, near1, near2},

 dists = Table[GeoDistance[{lat, lon}, Reverse[i]], {i, s};
 {near1, near2} = Ordering[dists, {1,2}];

(* got bored of this *)


(* TODO: may not work if across more than half globe *)

did i give up on geodistance 20180829.13

t1323[lon_, lat_] := metrosUSATop[[Ordering[
 Table[GeoDistance[i[[4]], {lat, lon}], {i, metrosUSATop}]
][[1]]]];

t1323[lon_, lat_] := Ordering[
 Table[GeoDistance[i[[4]], {lat, lon}], {i, metrosUSATop}]
][[1]];

t1327 = Timing[
 Table[{lon, lat, t1323[lon, lat]}, {lon, -120, -90}, {lat, 30, 49}]
];

13.8231 seconds for above, 620 pts

(* the 4 points rule like I use in that other thing? *)

bc-closest-gmap or something

(* Given a lon/lat rectangle and a function that returns nearest point
given lon/lat, return nearest point if all nearest points are identical, false otherwise *)

t1403[{lon1_, lat1_}, {lon2_, lat2_}, f_] := Module[{p1, p2, p3, p4},

  p1 = f[lon1,lat1];
  p2 = f[lon2,lat1];
  p3 = f[lon2,lat2];
  p4 = f[lon1,lat2];
  (* testing *)
  Print[p1];
  Print[p2];
  Print[p3];
  Print[p4];
  If[p1 == p2 == p3 == p4, Return[p1], Return[False]];
];

(* Given a lon/lat rectangle, return four sub-rectangles (trivial) *)

t1414[{lon1_, lat1_}, {lon2_, lat2_}] = {
 { {lon1, lat1}, {(lon1+lon2)/2, (lat1+lat2)/2} },
 { {(lon1+lon2)/2, lat1}, {lon2, (lat1+lat2)/2} },
 { {lon1, (lat1+lat2)/2}, {(lon1+lon2)/2, lat2} },
 { {(lon1+lon2)/2, (lat1+lat2)/2}, {lon2, lat2} }
};


t1414[{-106.5, 35.5}, {-106, 36}]

Table[Rectangle[i[[1]], i[[2]]], {i, t1414[{-106.5, 35.5}, {-106, 36}]}]

Table[Flatten[{i, t1323}, 1], {i, t1414[{-106.5, 35.5}, {-106, 36}]}]

Table[Apply[t1403, Flatten[{i, t1323}, 1]], 
 {i, t1414[{-107, 35}, {-106, 36}]}]

(* the whole she-bang, hardcoding for now *)

t1439[{lon1_, lat1_}, {lon2_, lat2_}] := Module[{s},

 Print["t1439({",lon1,", ",lat1,"}, {",lon2,", ",lat2,"})"];

 (* TODO: refine stopping condition *)
 If[Abs[lon1-lon2] < 0.01 && Abs[lat1-lat2] < 0.01, Return[]];

(* TODO: if p1 != p2, could go straight to division there *)

  p1 = t1323[lon1,lat1];
  p2 = t1323[lon2,lat1];
  p3 = t1323[lon2,lat2];
  p4 = t1323[lon1,lat2];

  If[p1 == p2 == p3 == p4, Return[{{lon1,lat1}, {lon2,lat2}, p1}]];

  s = t1414[{lon1, lat1}, {lon2, lat2}];
  Return[Table[Apply[t1439, i], {i, s}]];

];

t1439[{-107., 35.}, {-106., 36.}]


  Print["S:", s, "S1:", s[[1]], "APPLY:", Apply[t1439,s[[1]]]];




t1403[{-107, 35}, {-106, 36}, t1323]

t1403[-106.5, 35.5, -106, 36, t1323]



  
 




t1323[-106.5, 35]

approach of 20180811.17 below

rc = Table[RandomReal[1,3], {i,1,50}];

(* assign colors to each area *)

Table[f[geopos[[i]]] = rc[[i]], {i, 1, Length[geopos]}];

usapoly = rectifyCoords[Entity["Country","USA"]["Polygon"][[1,1,1]]];

t1712 = RegionNearest[Point[geopos]];

t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]],
 {lon,-180,180,1}, {lat,-90,90,1}];

t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]], {lat,25,55,.1},
 {lon,-120,-70,.1}];

t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]], {lat,25,55,30/4096},
 {lon,-120,-70,50/8192}];

t1809 = Table[{(i[[1]]+120)/.1, (i[[2]]-25)/.1}, {i, usapoly}]

Graphics[{Raster[t1716], Line[usapoly]}, Axes -> True]


Graphics[{
 Scale[Raster[t1716], {1/10,1/10}, {0,0}], Line[usapoly]}, Axes -> True]


Graphics[{
 Translate[Scale[Raster[t1716], {1/10,1/10}, {0,0}], {-120, 25}], Line[usapoly]
}, Axes -> True]

t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]], {lat,25,50,.02},
 {lon,-125,-66,.02}];

t1854 = Graphics[{
 Translate[Scale[Raster[t1716], {1/50,1/50}, {0,0}], {-125, 25}], Line[usapoly]
}, Axes -> True, AspectRatio -> 1/2];


t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]], {lat,40,41,1/256},
 {lon,-90,-89,1/256}];

t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]], {lat,40,41,1/1024},
 {lon,-90,-89,1/1024}];

Graphics[Raster[t1716], Frame -> False, PlotRangePadding -> 0];
Export["/tmp/temp.jpg", %, ImageSize -> {1024,1024}]

Offset and Scaled

Grid[Table[Hue[h,s,1], {h,0,1,1/16}, {s,0,1,1/16}]];

Grid[Table[Hue[h,s,s], {h,0,1,1/16}, {s,1/2,1,1/16}]];

Grid[Table[LABColor[1,a,b], {a,0,1,1/16}, {b,0,1,1/16}]];











Translate[Raster[t1716], {-120, 25}]

Graphics[{Translate[Raster[t1716], {-120, 25}], Line[usapoly]}]

Graphics[{
 Scale[Translate[Raster[t1716], {-120, 25}], {1/10, 1/10}], Line[usapoly]}]


Graphics[{
 Translate[Scale[Raster[t1716], {1/10, 1/10}], {-120, 25}], Line[usapoly]}]

Graphics[{
 Scale[Raster[t1716], {1/10, 1/10}], Line[usapoly]}]



raster vs squares w/ position?

t1751 = Table[{RandomColor[], Rectangle[{x,y}, {x+1,y+1}]}, 
 {x, 1, 100}, {y, 1, 100}];

t1751 = Table[{RandomColor[], Rectangle[{x,y}, {x+1,y+1}]}, 
 {x, 1, 8192}, {y, 1, 4096}];

t1804 = Raster[Table[{x, y, 0}, {x, 0, 1, 0.1}, {y, 0, 1, 0.1}]]

Show[{Graphics[t1804], Graphics[Circle[{0,0}, 5]]}]















t1131 = Nearest[geopos];

t1953 = ImplicitRegion[t1131[{x,y,z}] == {1}, {{x,-1,1},{y,-1,1},{z,-1,1}}];

t1131[lonLatDeg2XYZ[lon, lat]] == {1},
 { {lon, -180, 180}, {lat, -90, 90}}];




t1131[lonLatDeg2XYZ[-106, 35]]

t1131[GeoPositionXYZ[GeoPosition[{35, -106}]][[1]]]

t1131[lonLatDeg2XYZ[-106, 35]];

t1257 = RegionPlot[t1131[lonLatDeg2XYZ[lon, lat]] == {1},
 {{lon, -180, 180}, {lat, -90, 90}}];

t1257 = RegionPlot[t1131[lonLatDeg2XYZ[lon, lat]] == {1},
 {lon, -75, -70}, {lat, 40, 41}];

t1302 = Table[
 RegionPlot[t1131[lonLatDeg2XYZ[lon, lat]] == {i},
 {lon, -180, 180}, {lat, -90, 90}], {i, 1, 50}];

t1302 = Table[
 RegionPlot[t1131[lonLatDeg2XYZ[lon, lat]] == {i},
 {lon, -124.733, -66.9498}, {lat, 25.1246, 49.3845}, 
 ImageSize -> {8192, 4096}], 
 {i, 1, 50}];

t1308 =
Graphics[Line[rectifyCoords[Entity["Country","USA"]["Polygon"][[1,1,1]]
]]]


Show[{t1302, t1308}, AspectRatio -> 1/2]







RegionPlot[t1131[lonLatDeg2XYZ[-106, 35]] == {1}, 
 {lon, -124.733, -66.9498}, {lat, 25.1246, 49.3845}, 
 ImageSize -> {8192, 4096}];





regions = Table[
 RegionPlot[t1131[GeoPosition[{lat,lon}]] == t1131[i[[1]]],
 {lon, -180, 180}, {lat, -90, 90}], {i, geopos}];

regions = Table[
 RegionPlot[t1131[GeoPosition[{lat,lon}]] == t1131[i[[1]]],
 {lon, -124.733, -66.9498}, {lat, 25.1246, 49.3845}], {i, geopos}];











example:

closestMetros[[7,2]]

closestMetros[[7,2,1,3]] gives population of includer

Transpose[Transpose[closestMetros[[7]]][[1]]][[3]] is just pops

NOTE: can't use census blockgroups -- for 2017, their data only goes
down to cities + micro/metro politans, not blockgroups


In[50]:= Nearest[Table[i[[4]] -> i[[1]], {i, metrosUSATop}], metrosUSASorted[[55
5,4]]]                                                                          
above works

(* table of important values, including XYZ pos for distance *)

(* this assumes ellipsoidal Earth, shiny! *)

(* the Print[i] is just to track progress, not used for anything *)

metrosTable = Table[
 {i["Name"], i["Population"], i["Latitude"], i["Longitude"], 
  GeoPositionXYZ[i], Print[i]},
 {i, metrosUSA}];








(* Avoid long delays *)

EntityList["MetropolitanArea"] lists all

a2311 = Entity["MetropolitanArea"]["Properties"]                           

a2256 = EntityList["MetropolitanArea"];

a2257 = Entity["Country", "UnitedStates"]

a2258 = Select[a2256, #["Country"] == a2257 &];

a2259 = Select[a2256, #["Country"][[2]] == "UnitedStates" &];

a2303 = Table[{i, i["Country"][[2]], Print[i]}, {i, a2256}];

a2309 = Select[a2303, #[[2]] == "UnitedStates" &]

a2309[[5,1]]["Population"]
a2309[[5,1]]["Latitude"]
a2309[[5,1]]["Longitude"]


a2312 = Transpose[a2309][[1]]

a2313 = Table[
 {i["Name"], i["Population"], i["Latitude"], i["Longitude"], Print[i]},
 {i, a2312}];

a2328 = Table[
 {i["Name"], i["Population"], i["Latitude"], i["Longitude"], Print[i]},
 {i, a2258}];

Total[Transpose[a2328][[2]]]

292138739 people

That brings the country's total urban population to 249,253,271, a number attained via a growth rate of 12.1 percent between 2000 and 2010, outpacing the nation as a whole, which grew at 9.7 percent.

from https://www.citylab.com/equity/2012/03/us-urban-population-what-does-urban-really-mean/1589/

292138739/328122776. 

is 89% so quasi-reasonable

https://mathematica.stackexchange.com/questions/56172/speed-of-curated-data-calls-in-version-10
optimization (do NOT set `$AllowInternet = False`, that breaks stuff)

Take[Sort[a2328, #1[[2]] > #2[[2]] &],10]

working thru mathematica example

data = Table[
   Reverse[CityData[c, "Coordinates"]] -> CityData[c, "Name"], {c, 
    CityData[{Large, "Italy"}]}];

city = Nearest[data];

approach of 20180809 (and using Entity not CityData)

top 50 cities

t1323 = Take[Entity["Country", "UnitedStates"]["LargestCities"], 50];

t1330 = Table[GeoPosition[i] -> i, {i, t1323}]

(* just the positions for Voronoi mesh.. *)

t1336 = Table[GeoPosition[i], {i, t1323}];

(* this is in lat, lon format *)

t1324 = Nearest[t1330];

t1334 = VoronoiMesh[t1330];


pts = RandomReal[{-1, 1}, {50, 2}];

test = VoronoiMesh[pts];

RegionPlot[t1324[GeoPosition[{lat, lon}]] == 
 t1324[GeoPosition[{34, 105}]], {lon, -120, 70}, {lat, 30, 50}]

RegionPlot[t1324[GeoPosition[{lat, lon}]] == 
 t1330[[5,2]], {lon, -120, 70}, {lat, 30, 50}]

t1418 = RegionPlot[t1324[GeoPosition[{lat, lon}]] == 
 t1324[t1330[[5,1]]], {lon, -120, -70}, {lat, 30, 50}]

t1418 = RegionPlot[t1324[GeoPosition[{lat, lon}]] == 
 t1324[t1330[[5,1]]], {lon, -120, -70}, {lat, 30, 50}, PlotStyle -> Red]

t1418 = RegionPlot[t1324[GeoPosition[{lat, lon}]] == 
 t1324[t1330[[5,1]]], {lon, -120, -70}, {lat, 30, 50}, PlotStyle -> Red,
 ImageSize -> {8192, 4096}]

t1418 = RegionPlot[t1324[GeoPosition[{lat, lon}]] == 
 t1324[t1330[[10,1]]], {lon, -120, -70}, {lat, 30, 50}, PlotStyle -> Red,
 ImageSize -> {8192, 4096}]

rc = RandomColor[50];

Show[{Graphics[rc[[1]]], t1418}];

approach 20180810

Solve[Norm[{x,y,z} - {0,0,0}]^2 < Norm[{x,y,z} - {1,2,3}]^2, Reals]

t2041 = Table[RandomReal[1,3], {i,1,10}]

t2043 = Table[Norm[{x,y,z}-t2041[[1]]]^2 < Norm[{x,y,z}-t2041[[i]]]^2,
 {i, 2, Length[t2041]}];

ImplicitRegion[Norm[{x,y,z}-t2041[[1]]]^2 < Norm[{x,y,z}-t2041[[2]]]^2,
 {{x,-1,1}, {y,-1,1}, {z,-1,1}}]

norm2[{x_,y_,z_}, {a_,b_,c_}] = (x-a)^2 + (y-b)^2 + (z-c)^2

norm2[{x,y,z},t2041[[1]]] < norm2[{x,y,z},t2041[[2]]]

t2051 = Table[norm2[{x,y,z}, t2041[[1]]] < norm2[{x,y,z}, t2041[[i]]],
 {i, 2, Length[t2041]}];


Norm[{x,y,z}-t2041[[1]]]^2 < Norm[{x,y,z}-t2041[[i]]]^2,

any 2 points a,b,c and d,e,f

closer[{x_, y_, z_}, {a_, b_, c_}, {d_, e_, f_}] = 
Simplify[Reduce[norm2[{x,y,z},{a,b,c}] < norm2[{x,y,z},{d,e,f}], Reals],
 Element[{x,y,z,a,b,c,d,e,f}, Reals]]

t2100 = Table[RandomReal[1,3],{i,3}];

closer[t2100[[1]], t2100[[2]], t2100[[3]]];

returns quickly, hmmm

t2103 = Table[closer[{x, y, z}, t2041[[1]], t2041[[i]]], {i, 2, Length[t2041]}]

t2104[x_, y_, z_] = Apply[And, t2103]

t2105 = ImplicitRegion[t2104[x,y,z], { {x,-1,1}, {y,-1,1}, {z,-1,1} }];

t2106 = RegionPlot3D[t2105]

t2108 = Map[Point, t2041]

Show[{t2106, Graphics3D[t2108]}]

example of 20180810.21

norm2[{x_,y_,z_}, {a_,b_,c_}] = (x-a)^2 + (y-b)^2 + (z-c)^2

closer[{x_, y_, z_}, {a_, b_, c_}, {a_, b_, c_}] = True;

closer[{x_, y_, z_}, {a_, b_, c_}, {d_, e_, f_}] = 
Simplify[Reduce[norm2[{x,y,z},{a,b,c}] < norm2[{x,y,z},{d,e,f}], Reals],
 Element[{x,y,z,a,b,c,d,e,f}, Reals]]

(a < 0 && 
  ((b < 0 && 
    ((c < 0 && ((f < 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
     (c == 0 && ((a == d && 
        ((((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] > 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y))) && 
          (b == e || a^2 + b^2 + 2*d*x + 2*e*y == d^2 + e^2 + 2*a*x + 
             2*b*y)) || (b != e && (f != 0 || a^2 + b^2 + 2*d*x + 2*e*y < 
            d^2 + e^2 + 2*a*x + 2*b*y) && (f == 0 || 
           a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
             2*b*y) && a^2 + b^2 + 2*d*x + 2*e*y != d^2 + e^2 + 2*a*x + 
            2*b*y))) || (b == e && ((a != d && (a^2 + b^2 - d^2 - e^2)/
            (a - d) == 2*x && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 
               2*b*y + 2*e*y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))) || (f == 0 && a != d && 
          a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x) || 
         (a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y && a != d && ((d^2 + e^2 + 2*a*x < a^2 + b^2 + 2*d*x && 
            f != 0) || a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x)))) || 
       (b != e && a != d && ((a^2 + b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*a*x + 
            2*b*y && (f == 0 || a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < 
            d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || (f != 0 && 
          a^2 + b^2 + 2*d*x + 2*e*y > d^2 + e^2 + 2*a*x + 2*b*y && 
          a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y) || ((a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x)/(b - e) == 
           2*y && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*
                y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))))))) || 
     (c > 0 && ((f > 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))))) || 
   (b == 0 && 
    ((c < 0 && ((a == d && ((c == f && ((Sqrt[a^2 - d^2] < e && 
            e*(a^2 + 2*d*x + 2*e*y) < e*(d^2 + e^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2] > e && e*(a^2 + 2*d*x + 2*e*y) > 
             e*(d^2 + e^2 + 2*a*x)))) || (a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z && (c < f || 
           (c > f && f < 0))))) || (c == f && 
        ((e == 0 && ((a < d && a + d > 2*x) || (a > d && a + d < 2*x))) || 
         (a != d && e != 0 && f < 0 && a^2 + 2*d*x + 2*e*y < 
           d^2 + e^2 + 2*a*x))) || ((c < f || (c > f && f < 0)) && 
        ((a != d && e == 0 && a^2 + c^2 + 2*d*x + 2*f*z < d^2 + f^2 + 2*a*x + 
            2*c*z) || (e != 0 && a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z))))) || 
     (c == 0 && ((e != 0 && ((a != d && ((a^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x && (f == 0 || a^2 + 2*d*x + 2*e*y + 2*f*z < 
              d^2 + e^2 + f^2 + 2*a*x)) || (f != 0 && a^2 + 2*d*x + 2*e*y > 
             d^2 + e^2 + 2*a*x && a^2 + 2*d*x + 2*e*y + 2*f*z < 
             d^2 + e^2 + f^2 + 2*a*x) || ((-a^2 + d^2 + 2*a*x - 2*d*x + e*
                (e - 2*y))/e == 0 && ((Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 
                 2*e*y] > f && f*(a^2 + 2*(d*x + e*y + f*z)) > f*
                (d^2 + e^2 + f^2 + 2*a*x)) || (Sqrt[a^2 - d^2 - e^2 - 2*a*x + 
                 2*d*x + 2*e*y] < f && f*(a^2 + 2*(d*x + e*y + f*z)) < f*
                (d^2 + e^2 + f^2 + 2*a*x)))))) || (a == d && 
          a^2 + 2*d*x + 2*e*y == d^2 + e^2 + 2*a*x && 
          ((Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] < f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) < f*(d^2 + e^2 + f^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] > f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) > f*(d^2 + e^2 + f^2 + 2*a*
                x)))))) || (e == 0 && ((a != d && a + d == 2*x && 
          ((Sqrt[(a - d)*(a + d - 2*x)] < f && f*(a^2 + 2*d*x + 2*f*z) < 
             f*(d^2 + f^2 + 2*a*x)) || (Sqrt[(a - d)*(a + d - 2*x)] > f && 
            f*(a^2 + 2*d*x + 2*f*z) > f*(d^2 + f^2 + 2*a*x)))) || 
         (f == 0 && ((a < d && a + d > 2*x) || (a > d && a + d < 2*x))) || 
         (a^2 + 2*d*x + 2*f*z < d^2 + f^2 + 2*a*x && 
          ((f != 0 && ((a < d && a + d < 2*x) || (a > d && a + d > 2*x))) || 
           (a < d && a + d > 2*x) || (a > d && a + d < 2*x))))) || 
       (a == d && ((Sqrt[a^2 - d^2] == e && 
          ((Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] < f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) < f*(d^2 + e^2 + f^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] > f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) > f*(d^2 + e^2 + f^2 + 2*a*x)))) || 
         (f == 0 && ((Sqrt[a^2 - d^2] < e && e*(a^2 + 2*d*x + 2*e*y) < 
             e*(d^2 + e^2 + 2*a*x)) || (Sqrt[a^2 - d^2] > e && 
            e*(a^2 + 2*d*x + 2*e*y) > e*(d^2 + e^2 + 2*a*x)))) || 
         (Sqrt[a^2 - d^2] != e && f != 0 && e*(a^2 + 2*d*x + 2*e*y) != 
           e*(d^2 + e^2 + 2*a*x) && a^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x))))) || 
     (c > 0 && ((a == d && ((c == f && ((Sqrt[a^2 - d^2] < e && 
            e*(a^2 + 2*d*x + 2*e*y) < e*(d^2 + e^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2] > e && e*(a^2 + 2*d*x + 2*e*y) > 
             e*(d^2 + e^2 + 2*a*x)))) || (a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z && (c > f || 
           (c < f && f > 0))))) || (c == f && 
        ((e == 0 && ((a < d && a + d > 2*x) || (a > d && a + d < 2*x))) || 
         (a != d && e != 0 && f > 0 && a^2 + 2*d*x + 2*e*y < 
           d^2 + e^2 + 2*a*x))) || ((c > f || (c < f && f > 0)) && 
        ((a != d && e == 0 && a^2 + c^2 + 2*d*x + 2*f*z < d^2 + f^2 + 2*a*x + 
            2*c*z) || (e != 0 && a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z))))))) || 
   (b > 0 && 
    ((c < 0 && ((f < 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
     (c == 0 && ((a == d && 
        ((((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] > 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y))) && 
          (b == e || a^2 + b^2 + 2*d*x + 2*e*y == d^2 + e^2 + 2*a*x + 
             2*b*y)) || (b != e && (f != 0 || a^2 + b^2 + 2*d*x + 2*e*y < 
            d^2 + e^2 + 2*a*x + 2*b*y) && (f == 0 || 
           a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
             2*b*y) && a^2 + b^2 + 2*d*x + 2*e*y != d^2 + e^2 + 2*a*x + 
            2*b*y))) || (b == e && ((a != d && (a^2 + b^2 - d^2 - e^2)/
            (a - d) == 2*x && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 
               2*b*y + 2*e*y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))) || (f == 0 && a != d && 
          a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x) || 
         (a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y && a != d && ((d^2 + e^2 + 2*a*x < a^2 + b^2 + 2*d*x && 
            f != 0) || a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x)))) || 
       (b != e && a != d && ((a^2 + b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*a*x + 
            2*b*y && (f == 0 || a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < 
            d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || (f != 0 && 
          a^2 + b^2 + 2*d*x + 2*e*y > d^2 + e^2 + 2*a*x + 2*b*y && 
          a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y) || ((a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x)/(b - e) == 
           2*y && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*
                y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))))))) || 
     (c > 0 && ((f > 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))))))) || 
 (a == 0 && 
  ((b < 0 && ((c < 0 && ((c == f && (((b != e || b^2 + 2*d*x < d^2 + e^2) && 
          (b == e || b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*b*y) && d != 0 && 
          f < 0) || (d == 0 && ((b < e && b + e > 2*y) || 
           (b > e && b + e < 2*y))))) || ((c < f || (c > f && f < 0)) && 
        ((d == 0 && b^2 + c^2 + 2*e*y + 2*f*z < e^2 + f^2 + 2*b*y + 2*c*z) || 
         (d != 0 && b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
            2*b*y + 2*c*z))))) || (c == 0 && 
      ((d < 0 && ((e < b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y) || ((b^2 - d^2 - e^2 + 2*d*x)/(b - e) == 2*y && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)))) || (b == e && ((d*(-b^2 + d^2 + e^2 - 2*d*x) > 0 && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y) || (x == (-b^2 + d^2 + e^2)/(2*d) && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (d*(-b^2 + d^2 + e^2 - 2*d*x) < 0 && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)))) || (e > b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/
              (2*b - 2*e) && (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < 
              d^2 + e^2 + f^2 + 2*b*y)) || ((b^2 - d^2 - e^2 + 2*d*x)/
              (b - e) == 2*y && ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 
                 2*e*y] && f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 
                 2*e*y - 2*f*z) < 0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 
                 2*b*y + 2*e*y] && f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 
                 2*b*y - 2*e*y - 2*f*z) > 0))) || 
           (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && f != 0 && 
            b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*y))))) || 
       (d == 0 && ((((Sqrt[(b - e)*(b + e - 2*y)] < f && 
            f*(b^2 + 2*e*y + 2*f*z) < f*(e^2 + f^2 + 2*b*y)) || 
           (Sqrt[(b - e)*(b + e - 2*y)] > f && f*(b^2 + 2*e*y + 2*f*z) > 
             f*(e^2 + f^2 + 2*b*y))) && (b == e || b + e == 2*y)) || 
         (f == 0 && ((b + e > 2*y && b < e) || (b > e && b + e < 2*y))) || 
         (b^2 + 2*e*y + 2*f*z < e^2 + f^2 + 2*b*y && 
          ((((b < e && b + e < 2*y) || (b > e && b + e > 2*y)) && f != 0) || 
           (b + e > 2*y && b < e) || (b > e && b + e < 2*y))))) || 
       (d > 0 && ((e < b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y) || ((b^2 - d^2 - e^2 + 2*d*x)/(b - e) == 2*y && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)))) || (b == e && ((d*(-b^2 + d^2 + e^2 - 2*d*x) > 0 && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)) || (x == (-b^2 + d^2 + e^2)/(2*d) && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (d*(-b^2 + d^2 + e^2 - 2*d*x) < 0 && f != 0 && 
            b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*y))) || 
         (e > b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)) || ((b^2 - d^2 - e^2 + 2*d*x)/(b - e) == 2*y && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y))))))) || (c > 0 && 
      ((c == f && (((b != e || b^2 + 2*d*x < d^2 + e^2) && 
          (b == e || b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*b*y) && d != 0 && 
          f > 0) || (d == 0 && ((b < e && b + e > 2*y) || 
           (b > e && b + e < 2*y))))) || ((c > f || (c < f && f > 0)) && 
        ((d == 0 && b^2 + c^2 + 2*e*y + 2*f*z < e^2 + f^2 + 2*b*y + 2*c*z) || 
         (d != 0 && b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
            2*b*y + 2*c*z))))))) || 
   (b == 0 && 
    ((d != 0 && ((e != 0 && ((c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*c*z && ((c > f && (c > 0 || 
             (c < 0 && f < 0))) || (c < f && (c < 0 || (c > 0 && 
              f > 0))))) || (c == f && d^2 + e^2 - 2*e*y > 2*d*x && 
          ((c > 0 && f > 0) || (c < 0 && f < 0))))) || 
       (e == 0 && c^2 + 2*d*x + 2*f*z < d^2 + f^2 + 2*c*z && 
        ((c > f && (c > 0 || (c < 0 && f < 0))) || 
         (c < f && (c < 0 || (c > 0 && f > 0))))))) || 
     (e != 0 && ((d == 0 && ((c^2 + 2*e*y + 2*f*z < e^2 + f^2 + 2*c*z && 
          ((c > f && (c > 0 || (c < 0 && f < 0))) || (c < f && 
            (c < 0 || (c > 0 && f > 0))))) || (c == 0 && e == 2*y && 
          ((Sqrt[-(e*(e - 2*y))] > f && f*(e^2 + f^2) < 2*f*(e*y + f*z)) || 
           (Sqrt[-(e*(e - 2*y))] < f && f*(e^2 + f^2) > 
             2*f*(e*y + f*z)))))) || (c == 0 && d != 0 && 
        ((d^2 + e^2 - 2*e*y > 2*d*x && (f == 0 || d^2 + e^2 + f^2 > 
            2*(d*x + e*y + f*z))) || (f != 0 && d^2 + e*(e - 2*y) < 2*d*x && 
          d^2 + e^2 + f^2 > 2*(d*x + e*y + f*z)) || 
         (d^2/e + e == 2*((d*x)/e + y) && 
          ((Sqrt[-d^2 - e^2 + 2*d*x + 2*e*y] > f && f*(d^2 + e^2 + f^2) < 
             2*f*(d*x + e*y + f*z)) || (Sqrt[-d^2 - e^2 + 2*d*x + 2*e*y] < 
             f && f*(d^2 + e^2 + f^2) > 2*f*(d*x + e*y + f*z)))))))) || 
     (d == 0 && ((c == 0 && ((e == 0 && ((f < 0 && f < 2*z) || 
           (f > 0 && f > 2*z))) || (f == 0 && ((e < 0 && e < 2*y) || 
           (e > 0 && e > 2*y))) || (e != 0 && f != 0 && e != 2*y && 
          e^2 + f^2 - 2*f*z > 2*e*y))) || (c != 0 && 
        ((c == f && ((e < 0 && e < 2*y) || (e > 0 && e > 2*y))) || 
         (e == 0 && ((c + f > 2*z && c < f) || (c > f && 
            c + f < 2*z))))))) || (e == 0 && 
      ((c != 0 && c == f && ((d > 0 && d > 2*x) || (d < 0 && d < 2*x))) || 
       (c == 0 && ((d == 2*x && d != 0 && ((Sqrt[-(d*(d - 2*x))] > f && 
            f*(d^2 + f^2) < 2*f*(d*x + f*z)) || 
           (f*(d^2 + f^2) > 2*f*(d*x + f*z) && Sqrt[-(d*(d - 2*x))] < f))) || 
         (f == 0 && ((d < 0 && d < 2*x) || (d > 0 && d > 2*x))) || 
         (d^2 + f^2 - 2*f*z > 2*d*x && ((((d > 2*x && d < 0) || 
             (d > 0 && d < 2*x)) && f != 0) || (d < 0 && d < 2*x) || 
           (d > 0 && d > 2*x))))))))) || 
   (b > 0 && ((c < 0 && ((c == f && (((b != e || b^2 + 2*d*x < d^2 + e^2) && 
          (b == e || b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*b*y) && d != 0 && 
          f < 0) || (d == 0 && ((b < e && b + e > 2*y) || 
           (b > e && b + e < 2*y))))) || ((c < f || (c > f && f < 0)) && 
        ((d == 0 && b^2 + c^2 + 2*e*y + 2*f*z < e^2 + f^2 + 2*b*y + 2*c*z) || 
         (d != 0 && b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
            2*b*y + 2*c*z))))) || (c == 0 && 
      ((d < 0 && ((e < b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y) || ((b^2 - d^2 - e^2 + 2*d*x)/(b - e) == 2*y && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)))) || (b == e && ((d*(-b^2 + d^2 + e^2 - 2*d*x) > 0 && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y) || (x == (-b^2 + d^2 + e^2)/(2*d) && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (d*(-b^2 + d^2 + e^2 - 2*d*x) < 0 && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)))) || (e > b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/
              (2*b - 2*e) && (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < 
              d^2 + e^2 + f^2 + 2*b*y)) || ((b^2 - d^2 - e^2 + 2*d*x)/
              (b - e) == 2*y && ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 
                 2*e*y] && f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 
                 2*e*y - 2*f*z) < 0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 
                 2*b*y + 2*e*y] && f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 
                 2*b*y - 2*e*y - 2*f*z) > 0))) || 
           (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && f != 0 && 
            b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*y))))) || 
       (d == 0 && ((((Sqrt[(b - e)*(b + e - 2*y)] < f && 
            f*(b^2 + 2*e*y + 2*f*z) < f*(e^2 + f^2 + 2*b*y)) || 
           (Sqrt[(b - e)*(b + e - 2*y)] > f && f*(b^2 + 2*e*y + 2*f*z) > 
             f*(e^2 + f^2 + 2*b*y))) && (b == e || b + e == 2*y)) || 
         (f == 0 && ((b + e > 2*y && b < e) || (b > e && b + e < 2*y))) || 
         (b^2 + 2*e*y + 2*f*z < e^2 + f^2 + 2*b*y && 
          ((((b < e && b + e < 2*y) || (b > e && b + e > 2*y)) && f != 0) || 
           (b + e > 2*y && b < e) || (b > e && b + e < 2*y))))) || 
       (d > 0 && ((e < b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y) || ((b^2 - d^2 - e^2 + 2*d*x)/(b - e) == 2*y && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)))) || (b == e && ((d*(-b^2 + d^2 + e^2 - 2*d*x) > 0 && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)) || (x == (-b^2 + d^2 + e^2)/(2*d) && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (d*(-b^2 + d^2 + e^2 - 2*d*x) < 0 && f != 0 && 
            b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*y))) || 
         (e > b && ((y < (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            (f == 0 || b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*b*
                y)) || ((b^2 - d^2 - e^2 + 2*d*x)/(b - e) == 2*y && 
            ((f < Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) < 
               0) || (f > Sqrt[b^2 - d^2 - e^2 + 2*d*x - 2*b*y + 2*e*y] && 
              f*(-b^2 + d^2 + e^2 + f^2 - 2*d*x + 2*b*y - 2*e*y - 2*f*z) > 
               0))) || (y > (b^2 - d^2 - e^2 + 2*d*x)/(2*b - 2*e) && 
            f != 0 && b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
              2*b*y))))))) || (c > 0 && 
      ((c == f && (((b != e || b^2 + 2*d*x < d^2 + e^2) && 
          (b == e || b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*b*y) && d != 0 && 
          f > 0) || (d == 0 && ((b < e && b + e > 2*y) || 
           (b > e && b + e < 2*y))))) || ((c > f || (c < f && f > 0)) && 
        ((d == 0 && b^2 + c^2 + 2*e*y + 2*f*z < e^2 + f^2 + 2*b*y + 2*c*z) || 
         (d != 0 && b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 
            2*b*y + 2*c*z))))))))) || 
 (a > 0 && 
  ((b < 0 && 
    ((c < 0 && ((f < 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
     (c == 0 && ((a == d && 
        ((((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] > 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y))) && 
          (b == e || a^2 + b^2 + 2*d*x + 2*e*y == d^2 + e^2 + 2*a*x + 
             2*b*y)) || (b != e && (f != 0 || a^2 + b^2 + 2*d*x + 2*e*y < 
            d^2 + e^2 + 2*a*x + 2*b*y) && (f == 0 || 
           a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
             2*b*y) && a^2 + b^2 + 2*d*x + 2*e*y != d^2 + e^2 + 2*a*x + 
            2*b*y))) || (b == e && ((a != d && (a^2 + b^2 - d^2 - e^2)/
            (a - d) == 2*x && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 
               2*b*y + 2*e*y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))) || (f == 0 && a != d && 
          a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x) || 
         (a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y && a != d && ((d^2 + e^2 + 2*a*x < a^2 + b^2 + 2*d*x && 
            f != 0) || a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x)))) || 
       (b != e && a != d && ((a^2 + b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*a*x + 
            2*b*y && (f == 0 || a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < 
            d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || (f != 0 && 
          a^2 + b^2 + 2*d*x + 2*e*y > d^2 + e^2 + 2*a*x + 2*b*y && 
          a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y) || ((a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x)/(b - e) == 
           2*y && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*
                y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))))))) || 
     (c > 0 && ((f > 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))))) || 
   (b == 0 && 
    ((c < 0 && ((a == d && ((c == f && ((Sqrt[a^2 - d^2] < e && 
            e*(a^2 + 2*d*x + 2*e*y) < e*(d^2 + e^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2] > e && e*(a^2 + 2*d*x + 2*e*y) > 
             e*(d^2 + e^2 + 2*a*x)))) || (a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z && (c < f || 
           (c > f && f < 0))))) || (c == f && 
        ((e == 0 && ((a < d && a + d > 2*x) || (a > d && a + d < 2*x))) || 
         (a != d && e != 0 && f < 0 && a^2 + 2*d*x + 2*e*y < 
           d^2 + e^2 + 2*a*x))) || ((c < f || (c > f && f < 0)) && 
        ((a != d && e == 0 && a^2 + c^2 + 2*d*x + 2*f*z < d^2 + f^2 + 2*a*x + 
            2*c*z) || (e != 0 && a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z))))) || 
     (c == 0 && ((e != 0 && ((a != d && ((a^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x && (f == 0 || a^2 + 2*d*x + 2*e*y + 2*f*z < 
              d^2 + e^2 + f^2 + 2*a*x)) || (f != 0 && a^2 + 2*d*x + 2*e*y > 
             d^2 + e^2 + 2*a*x && a^2 + 2*d*x + 2*e*y + 2*f*z < 
             d^2 + e^2 + f^2 + 2*a*x) || ((-a^2 + d^2 + 2*a*x - 2*d*x + e*
                (e - 2*y))/e == 0 && ((Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 
                 2*e*y] > f && f*(a^2 + 2*(d*x + e*y + f*z)) > f*
                (d^2 + e^2 + f^2 + 2*a*x)) || (Sqrt[a^2 - d^2 - e^2 - 2*a*x + 
                 2*d*x + 2*e*y] < f && f*(a^2 + 2*(d*x + e*y + f*z)) < f*
                (d^2 + e^2 + f^2 + 2*a*x)))))) || (a == d && 
          a^2 + 2*d*x + 2*e*y == d^2 + e^2 + 2*a*x && 
          ((Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] < f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) < f*(d^2 + e^2 + f^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] > f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) > f*(d^2 + e^2 + f^2 + 2*a*
                x)))))) || (e == 0 && ((a != d && a + d == 2*x && 
          ((Sqrt[(a - d)*(a + d - 2*x)] < f && f*(a^2 + 2*d*x + 2*f*z) < 
             f*(d^2 + f^2 + 2*a*x)) || (Sqrt[(a - d)*(a + d - 2*x)] > f && 
            f*(a^2 + 2*d*x + 2*f*z) > f*(d^2 + f^2 + 2*a*x)))) || 
         (f == 0 && ((a < d && a + d > 2*x) || (a > d && a + d < 2*x))) || 
         (a^2 + 2*d*x + 2*f*z < d^2 + f^2 + 2*a*x && 
          ((f != 0 && ((a < d && a + d < 2*x) || (a > d && a + d > 2*x))) || 
           (a < d && a + d > 2*x) || (a > d && a + d < 2*x))))) || 
       (a == d && ((Sqrt[a^2 - d^2] == e && 
          ((Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] < f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) < f*(d^2 + e^2 + f^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2 - e^2 - 2*a*x + 2*d*x + 2*e*y] > f && 
            f*(a^2 + 2*(d*x + e*y + f*z)) > f*(d^2 + e^2 + f^2 + 2*a*x)))) || 
         (f == 0 && ((Sqrt[a^2 - d^2] < e && e*(a^2 + 2*d*x + 2*e*y) < 
             e*(d^2 + e^2 + 2*a*x)) || (Sqrt[a^2 - d^2] > e && 
            e*(a^2 + 2*d*x + 2*e*y) > e*(d^2 + e^2 + 2*a*x)))) || 
         (Sqrt[a^2 - d^2] != e && f != 0 && e*(a^2 + 2*d*x + 2*e*y) != 
           e*(d^2 + e^2 + 2*a*x) && a^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x))))) || 
     (c > 0 && ((a == d && ((c == f && ((Sqrt[a^2 - d^2] < e && 
            e*(a^2 + 2*d*x + 2*e*y) < e*(d^2 + e^2 + 2*a*x)) || 
           (Sqrt[a^2 - d^2] > e && e*(a^2 + 2*d*x + 2*e*y) > 
             e*(d^2 + e^2 + 2*a*x)))) || (a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z && (c > f || 
           (c < f && f > 0))))) || (c == f && 
        ((e == 0 && ((a < d && a + d > 2*x) || (a > d && a + d < 2*x))) || 
         (a != d && e != 0 && f > 0 && a^2 + 2*d*x + 2*e*y < 
           d^2 + e^2 + 2*a*x))) || ((c > f || (c < f && f > 0)) && 
        ((a != d && e == 0 && a^2 + c^2 + 2*d*x + 2*f*z < d^2 + f^2 + 2*a*x + 
            2*c*z) || (e != 0 && a^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*c*z))))))) || 
   (b > 0 && 
    ((c < 0 && ((f < 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
     (c == 0 && ((a == d && 
        ((((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] > 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y))) && 
          (b == e || a^2 + b^2 + 2*d*x + 2*e*y == d^2 + e^2 + 2*a*x + 
             2*b*y)) || (b != e && (f != 0 || a^2 + b^2 + 2*d*x + 2*e*y < 
            d^2 + e^2 + 2*a*x + 2*b*y) && (f == 0 || 
           a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
             2*b*y) && a^2 + b^2 + 2*d*x + 2*e*y != d^2 + e^2 + 2*a*x + 
            2*b*y))) || (b == e && ((a != d && (a^2 + b^2 - d^2 - e^2)/
            (a - d) == 2*x && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 
               2*b*y + 2*e*y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))) || (f == 0 && a != d && 
          a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x) || 
         (a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y && a != d && ((d^2 + e^2 + 2*a*x < a^2 + b^2 + 2*d*x && 
            f != 0) || a^2 + b^2 + 2*d*x < d^2 + e^2 + 2*a*x)))) || 
       (b != e && a != d && ((a^2 + b^2 + 2*d*x + 2*e*y < d^2 + e^2 + 2*a*x + 
            2*b*y && (f == 0 || a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < 
            d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || (f != 0 && 
          a^2 + b^2 + 2*d*x + 2*e*y > d^2 + e^2 + 2*a*x + 2*b*y && 
          a^2 + b^2 + 2*d*x + 2*e*y + 2*f*z < d^2 + e^2 + f^2 + 2*a*x + 
            2*b*y) || ((a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x)/(b - e) == 
           2*y && ((Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*
                y] > f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) > 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)) || 
           (Sqrt[a^2 + b^2 - d^2 - e^2 - 2*a*x + 2*d*x - 2*b*y + 2*e*y] < 
             f && f*(a^2 + b^2 + 2*(d*x + e*y + f*z)) < 
             f*(d^2 + e^2 + f^2 + 2*a*x + 2*b*y)))))))) || 
     (c > 0 && ((f > 0 && ((c == f && ((b == e && a^2 + b^2 + 2*d*x < 
             d^2 + e^2 + 2*a*x && a != d) || (a^2 + b^2 + 2*d*x + 2*e*y < 
             d^2 + e^2 + 2*a*x + 2*b*y && b != e))) || 
         (c < f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
           d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z))) || 
       (c > f && a^2 + b^2 + c^2 + 2*d*x + 2*e*y + 2*f*z < 
         d^2 + e^2 + f^2 + 2*a*x + 2*b*y + 2*c*z)))))))

t2120 = Table[RandomReal[1,3], {i,1,500}]

t2125 = Apply[And,Table[closer[{x,y,z}, t2120[[7]], i], {i, t2120}]];

t2126[x_, y_, z_] = t2125

ImplicitRegion[t2126[x,y,z], {{x,0,1}, {y,0,1}, {z,0,1}}]

approach 20180811 two d points on surface of sphere

t0931 = Table[{Random[]*360-180, Random[]*180-90}, {i,1,100}];

t0932 = Map[lonLatDeg2XYZ,t0931];

convert back

Table[f[t0932[[i]]] = i, {i, 1, Length[t0932]}]

these points do form a region, so

t0933 = Point[t0932]

RegionNearest[t0933, {0,0,0}];

ContourPlot[f[RegionNearest[t0933, lonLatDeg2XYZ[lon, lat]]], 
 {lon, -180, 180}, {lat, -90, 90}]

t0954 = ContourPlot[f[RegionNearest[t0933, lonLatDeg2XYZ[lon, lat]]], 
 {lon, -180, 180}, {lat, -90, 90}, Contours -> 100, ColorFunction -> Hue,
 ImageSize -> {8192, 4096}]

t0942 = Graphics[Point[t0931]]

Show[{t0954, t0942}];

t0944 = ImplicitRegion[RegionNearest[t0933, lonLatDeg2XYZ[lon, lat]] ==
RegionNearest[t0933, {0,0,0}], { {lon, -180, 180}, {lat, -90, 90}}];

ContourPlot[Sign[x]*Sign[y], {x,-1,1}, {y,-1,1}]

above worked well

ContourPlot[Floor[x]*Floor[y], {x,1,10}, {y,1,10}]

ContourPlot[Floor[x]*Floor[y], {x,1,100}, {y,1,100}]

lets see if point by point works

t1441 = Table[Point[{x,y}], {x,1,1000}, {y,1,1000}];

t1441 = Table[Point[{x,y}], {x,1,100}, {y,1,100}];

t1445 = Table[RandomReal[1,3], {i, 1, 10}, {j, 1, 10}];

Raster[t1445]

t1447 = Table[RandomReal[1,3], {i, 1, 1000}, {j, 1, 1000}];

above works nice and fast

ult test

t1448 = Table[RandomReal[1,3], {x, 1, 8192}, {y, 1, 4096}];

Graphics[Raster[t1448]]

very nice!!!

t1445 = Table[Prime[i*10+j], {i, 1, 10}, {j, 1, 10}];

fails miserably as expected!


t1445 = Table[RandomReal[1,3], {x, 1, 10}, {y, 1, 10}, {z, 1, 10}];

t1445 = Table[RandomReal[1,4], {x, 1, 10}, {y, 1, 10}, {z, 1, 10}];

t1445 = Table[RandomReal[1,4], {x, 1, 100}, {y, 1, 100}, {z, 1, 100}];

t1445 = Table[RandomReal[1,4], {x, 1, 1000}, {y, 1, 1000}, {z, 1, 1000}];


(* JFF matching of MAPS/bc-closest-gmap.pl =
http://test.barrycarter.info/gmap8.php *)

points = {
 {35.08, -106.66},
 {48.87, 2.33},
 {71.26826, -156.80627},
 {-41.2833, 174.783333},
 {-22.88,  -43.28}
};

t2050 = Table[sph2xyz[i[[2]]*Degree, i[[1]]*Degree, 1], {i, points}]

(* assign colors to each area *)

rc = Table[RandomReal[1,3], {i,1,50}];
Table[f[t2050[[i]]] = rc[[i]], {i, 1, Length[points]}];

t2051 = RegionNearest[Point[t2050]];

t2056 = Table[f[t2051[sph2xyz[lon*Degree, lat*Degree, 1]]], 
 {lat, -90, 90, 1}, {lon, -180, 180, 1}];

t2056 = Table[f[t2051[sph2xyz[lon*Degree, lat*Degree, 1]]], 
 {lat, -90, 90, 0.1}, {lon, -180, 180, 0.1}];

t2152 = Graphics[Raster[t2056]]

Graphics[Raster[t2056], Axes -> True]

t2145 = Entity["Country", "World"]["Polygon"];

t2146 = Apply[Line, t2145];

t2151 = Graphics[
 Scale[Translate[t2146, {180, 90}], {10, 10}], Axes -> True]

Show[{t2152, t2151}]


PlotRangePadding -> 0, ImagePadding -> 0, ImageSize -> {3600, 1800}]

Export["/tmp/temp.png", %, ImageSize -> {3600, 1800}]

<question>

Subject: If rectangle corner points have same nearest neighbor, does whole region?

Question: If all four corners of a spherical (but actually WGS84/elliptical) rectangle are closest to a given point `p` in a set `S`, does that necessarily mean all points inside the rectangle are also closest to `p`?

I'm trying to coax Mathematica into creating a geographical Voronoi map (my ugly efforts so far: https://github.com/barrycarter/bcapps/blob/master/REDDIT/bc-metro.m). This isn't too hard to do if I assume the Earth is spherical, but, as a form of self-loathing, I've decided to do this using the Earth's true shape, or at least WGS84.

Mathematica does have a WGS84 accurate `GeoDistance` function, but it's expensive to evaluate, so I want to use it as few times as possible.

My plan is to break up my region into latitude/longitude rectangles, and, if the 4 corner points are all closest to the same point in my set, assume the entire rectangular region is also closest to that point.

I'm pretty sure I could prove this on a perfect sphere, but I'm worried that it might not be true on an ellipsoid.

Ages ago, I created http://test.barrycarter.info/gmap8.php using this technique (https://github.com/barrycarter/bcapps/blob/master/MAPS/bc-closest-gmap.pl but the code is currently commented out, since I tried to use qhull instead)

gcdist marengo.ia.us kansas.city minneapolis chicago milwaukee
Marengo to Kansas City: 228 mi (367 km, 1.23/2.45/4.90 ltms)
Marengo to Minneapolis: 227 mi (366 km, 1.22/2.45/4.89 ltms)
Marengo to Chicago: 227 mi (366 km, 1.22/2.44/4.89 ltms)
Marengo to Milwaukee: 229 mi (368 km, 1.23/2.46/4.92 ltms)
Kansas City to Minneapolis: 411 mi (662 km, 2.21/4.42/8.84 ltms)
Kansas City to Chicago: 410 mi (660 km, 2.20/4.41/8.82 ltms)
Kansas City to Milwaukee: 441 mi (710 km, 2.37/4.74/9.47 ltms)
Minneapolis to Chicago: 355 mi (571 km, 1.91/3.81/7.62 ltms)
Minneapolis to Milwaukee: 298 mi (479 km, 1.60/3.20/6.40 ltms)
Chicago to Milwaukee: 83 mi (133 km, 0.45/0.89/1.79 ltms)

gcdist denver.city.tx oklahoma.city dallas austin san.antonio

Denver City to Oklahoma City: 349 mi (562 km, 1.87/3.75/7.50 ltms)
Denver City to Dallas: 349 mi (562 km, 1.88/3.75/7.51 ltms)
Denver City to Austin: 352 mi (567 km, 1.89/3.78/7.57 ltms)
Denver City to San Antonio: 354 mi (570 km, 1.90/3.80/7.61 ltms)
Oklahoma City to Dallas: 189 mi (305 km, 1.02/2.04/4.08 ltms)
Oklahoma City to Austin: 359 mi (578 km, 1.93/3.86/7.72 ltms)
Oklahoma City to San Antonio: 421 mi (678 km, 2.26/4.52/9.05 ltms)
Dallas to Austin: 182 mi (293 km, 0.98/1.96/3.92 ltms)
Dallas to San Antonio: 252 mi (406 km, 1.36/2.71/5.42 ltms)
Austin to San Antonio: 73 mi (118 km, 0.40/0.79/1.58 ltms)

TODO: can probably combine kml with client side opacity for image

