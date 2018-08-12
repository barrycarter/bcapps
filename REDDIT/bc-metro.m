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

(* reallow Internet after Mathematica stops being stupid *)

$AllowInternet = True;

approach of 20180811.17 below

rc = Table[RandomReal[1,3], {i,1,50}];

(* assign colors to each area *)

Table[f[geopos[[i]]] = rc[[i]], {i, 1, Length[geopos]}];

usapoly = rectifyCoords[Entity["Country","USA"]["Polygon"][[1,1,1]]];

t1712 = RegionNearest[Point[geopos]];

t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]],
 {lon,-180,180,1}, {lat,-90,90,1}];

t1716 = Table[f[t1712[lonLatDeg2XYZ[lon,lat]]], {lat,25,55,.1},
 {lon,-120,-70,.1}]

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



