https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

<oneoff>

(* things I did one off and then saved to bc-buffer-load.m.bz2 *)

worldpoly = Entity["Country", "World"]["Polygon"]; 
antpoly = Entity["Country", "Antarctica"]["Polygon"];

{
 {"worldpoly", worldpoly},
 {"antpoly", antpoly}
} >> bc-buffer-load.m

</oneoff>

<formulas>

(* this ugliness required because Mathematica apparently can't load
data properly at run time, see <oneoff> section above *)

load = <<"!bzcat /home/barrycarter/BCGIT/STACK/bc-buffer-load.m.bz2";

worldpoly = load[[1,2]];
antpoly = load[[2,2]];

allpoly = Join[worldpoly[[1,1]],antpoly[[1,1]],1];

(* for spherical Earth, this is about as good as it gets *)

earthRadius = 6371.0326914755643871;

(* the append below attaches the last point back to the first *)

poly2D23D[list_] := Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&, 
 Append[list, list[[1]]]];

(* given the straight line distance between two points on Earth in
Earth radii, convert to distance in km assuming spherical Earth *)

lineDist2geoDist[x_] = 2*ArcSin[x/2]*earthRadius;

geoDist2LineDist[x_] = 2*Sin[x/earthRadius/2];

(* the delta of longitudes at lat2 which are with distance d (given in
Earth radii) of lat, lon where lon is any longitude *)

lonRange[lat_, lat2_, d_] = ArcCos[Cos[d]*Sec[lat]*Sec[lat2] - 
     Tan[lat]*Tan[lat2]]

(* friendlier version using km and degrees *)

lonRange2[lat_, lat2_, d_] = lonRange[lat*Degree, lat2*Degree,
d/earthRadius]/Degree;

(* temporary def of show it for larger screen *)

showit := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {1200, 600}]; 
     Run[StringJoin["display -update 1 ", file, "&"]]; Return[file];];

(* this probably the worst possible way to reverse coords *)

rectifyCoords[list_] := Transpose[Reverse[Transpose[list]]];

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

earthRadius = Entity["Planet", "Earth"]["Radius"]/Quantity[1,"km"];

</formulas>

giving mathematica another chance NOT to disappoint me on 20180812

Run["bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2 >  /tmp/output.txt"];

t1258 = Timing[ReadList["/tmp/output.txt", {Number, Number, Number}]];

(* only took 28 seconds, what was I whining about? *)

t1045 = t1258[[2]];

dists = Transpose[t1045][[3]];

Min[dists] (* is -2513.32 *)
Max[dists] (* is 2694.96 *)

dists2 = (dists - Min[dists])/(Max[dists]-Min[dists]);

360/.04

(* I happen to know this is a 9000 x 4500 array, and reversing so high lats are higher on screen, north pointing *)

dists3 = Reverse[Partition[dists2, 9000]];

Graphics[Raster[dists3]];

look correctish, but with no 0 value, a bit odd

Graphics[Raster[dists3, ColorFunction -> Hue]];

Graphics[Raster[dists3, ColorFunction -> Hue, PlotLegend -> True]];

distsp = Select[dists, # > 0 &];

t1102 = Quantile[distsp, Table[i, {i,0,1,1/16}]];

timesout: QuantilePlot[dists3]

# hue = 0 to 0.4 for land (most inland = red = 0)
# hue = 0.5 to 0.8 for water (furthest out = 0.8 = violetish)

t1156 = Quantile[distsp, Table[i, {i,0,1,1/100}]];

above is wrong, adjust for size of grid first

4.4478 km = 0.4 deg

19.7829 km^2 for equator cell

maxarea = (earthRadius*2*Pi/360/25)^2

Table[{maxarea*Cos[i[[2]]*Degree], i[[3]]}, {i, Take[t1045,500]}]

t1210 = Table[{maxarea*Cos[i[[2]]*Degree], i[[3]]}, {i, t1045}];

t1212 = Gather[t1210, #1[[2]] == #2[[2]] &];

Clear[f];
f[x_] = 0;
Table[f[i[[2]]] = f[i[[2]]] + i[[1]], {i, Take[t1210, 50]}]

Clear[f];
f[x_] = 0;
Table[f[i[[2]]] = f[i[[2]]] + i[[1]], {i, t1210}];

df = DownValues[f];

exoeriment w/ smaller

Table[g[i] = i^2,  {i, 1, 10}]

ReleaseHold[DownValues[g][[4,1]] /. g -> q][[1]]

-156.34 57.18   -0.000100205
-52.18  65.02   0.000872067

nm precision, so do round some










TODO: add the antarctica -90 poly

TODO: disclaim lakes, quote caspian sea directly

TODO: link to higher level shoreliness (lakes, islands in lakes, ponds
in islands in lakes)

approach 20180806.21 is to use contour plot on 10x10 deg rectangles,
may actually work

t1242 = Table[Line[poly2D23D[i]], {i, allpoly}]; 

t1245 = Table[RegionDistance[i], {i, t1242}];

t1248[lon_, lat_] := 
 Min[Table[f[sph2xyz[lon*Degree, lat*Degree, 1]], {f, t1245}]];

t1215 = Table[rectifyCoords[i], {i, allpoly}];

t2126 = Graphics[Polygon[t1215]];

huey[h_] = Hue[h*7/8];

contours = Table[geoDist2LineDist[i], {i, 25, 25*64, 25}];

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 10}, {lat, 0, 10}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 10}, {lat, 0, 10}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> contours, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 10}, {lat, 0, 10}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> contours, 
 ImageSize -> {8192, 4096}]

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 10}, {lat, 0, 10}, 
 AspectRatio -> 1/2, ColorFunction -> huey, Contours -> contours, 
 ImageSize -> {8192, 4096}, Frame -> False, PlotRangePadding -> 0]

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 10}, {lat, 0, 10}, 
 AspectRatio -> 1/2, ColorFunction -> huey, Contours -> contours, 
 ImageSize -> {8192, 4096}, Frame -> False, PlotRangePadding -> 0,
 ContourLines -> False]

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 10}, {lat, 0, 10}, 
 AspectRatio -> 1/2, ColorFunction -> huey, Contours -> contours, 
 ImageSize -> {8192, 4096}, Frame -> False, PlotRangePadding -> 0,
 ContourLines -> False, ContourLabels -> True]

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 20}, {lat, 0, 20}, 
 AspectRatio -> 1/2, ColorFunction -> huey, Contours -> contours, 
 ImageSize -> {8192*2, 4096*2}, Frame -> False, PlotRangePadding -> 0,
 ContourLines -> False, ContourLabels -> True]

Export["/tmp/test.png", t2127, ImageSize -> {8192*2, 4096*2}]

Rasterize::bigraster: Not enough memory available to rasterize Cell expression.

t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 11.25}, {lat, 0, 11.25}, 
 AspectRatio -> 1/2, ColorFunction -> huey, Contours -> contours, 
 ImageSize -> {8192*2, 4096*2}, Frame -> False, PlotRangePadding -> 0,
 ContourLines -> False, ContourLabels -> True]


t2127 = ContourPlot[
 t1248[lon, lat], {lon, 0, 11.25}, {lat, 0, 11.25}, 
 AspectRatio -> 1/2, ColorFunction -> huey, Contours -> contours, 
 ImageSize -> {8192, 4096}, Frame -> False, PlotRangePadding -> 0,
 ContourLines -> False]

latlon= Flatten[Table[
 {lon, lat}, {lon, -180, 179.99, 11.25}, {lat, -90, 89.99, 11.25}
], 1]


lons = Drop[Table[i, {i, -180, 180, 11.25}], -1]
lats = Drop[Table[i, {i, -90, 90, 11.25}], -1]


Show[{t2127, t2126}]
Timing[Export["/tmp/test.png", %, ImageSize -> {8192, 4096}]]

showit

drawMap[lon_, lat_, delta_] := drawMap[lon, lat, delta] = 
 ContourPlot[
 t1248[lng, lati], {lng, lon, lon+delta}, {lati, lat, lat+delta}, 
 AspectRatio -> 1/2, ColorFunction -> huey, Contours -> contours, 
 ImageSize -> {8192, 4096}, Frame -> False, PlotRangePadding -> 0,
 ContourLines -> False];




approach 20180805.12 is to use polygon after all (I gave up on it earlier)

t1211 = Polygon[Table[poly2D23D[i], {i, allpoly}]];

Graphics3D[t1211];

t1213 = RegionDistance[t1211];

t1214 = ContourPlot[
 t1213[sph2xyz[lon*Degree, lat*Degree, 1]], {lon, -180, 180}, {lat, -90, 90}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

t1215 = Table[rectifyCoords[i], {i, allpoly}];

t1216 = Show[{t1214, Graphics[Polygon[t1215]]}];

t1226[lon_, lat_] := t1213[sph2xyz[{lon*Degree, lat*Degree, 1}]];

t1227 = RegionPlot[t1226[lon, lat] <= 0.01/8, {lon, -180, 180},
{lat, -90, 90}, AspectRatio -> 1/2];

t1227 = RegionPlot[t1226[lon, lat] <= 0.01, {lon, -180, 180},
{lat, -90, 90}, AspectRatio -> 1/2];

t1230 = Show[{t1227, Graphics[Polygon[t1215]]}];

t1240 = RegionPlot[t1226[lon, lat] <= 0.01/8, {lon,  -98.4375, -95.625},
{lat, 27.059, 29.535}, AspectRatio -> 1/2];

t1240 = RegionPlot[t1226[lon, lat] <= 0.01/8, {lon,  -98.4375, -95.625},
{lat, 27.059, 29.535}, AspectRatio -> 1/2, Mesh -> 20];

t1240 = RegionPlot[t1226[lon, lat] <= 0.01/8, {lon,  -99, -95},
{lat, 27, 31}, AspectRatio -> 1/2, Mesh -> 40];

t1243 = Show[{t1240, Graphics[Line[t1215]]}];








approach 20180804.16 is to see if using points makes it easier

t1625 = Flatten[allpoly, 1];

t1628 = Map[sph2xyz[#[[1]], #[[2]], 1]&, t1625];

t1629 = Point[t1628];

Graphics3D[{PointSize[0.01], t1629}];

Graphics3D[{PointSize[0.0001], t1629}];

the above is still a big ugly

Graphics3D[{PointSize[0.000001], t1629}];

ugly, but not relevant, so....

t1630 = RegionDistance[t1629];

t1633 = Table[GeoDistance[t1628[[i-1]], t1628[[i]]],
 {i, 2, Length[t1628]}];


approach 20180804 is to rationalize coords for more accuracy

allpoly2 = Rationalize[allpoly, 0];

t1227 = Table[Line[poly2D23D[i]], {i, allpoly2}];

t1233 = Graphics3D[t1227]

above hangs forever when I do "showit"

t1232 = Table[Line[poly2D23D[i]], {i, allpoly}];

Export["/tmp/test.png", t1233, ImageSize -> {8000, 6000}]

t1238 = RegionUnion[t1227];

t1239 = RegionDistance[t1238];

above takes forever... let's see what went wrong with older approaches?

t1242 = Table[Line[poly2D23D[i]], {i, allpoly}]; 

t1243 = RegionUnion[t1242];

t1244 = RegionDistance[t1243];

above takes forever, so we instead do...

t1245 = Table[RegionDistance[i], {i, t1242}];

t1248[lon_, lat_] := 
 Min[Table[f[sph2xyz[lon*Degree, lat*Degree, 1]], {f, t1245}]];

t1249 = RegionPlot[t1248[lon, lat] <= 0.01, {lon, -180, 180}, {lat, -90, 90}];

takes forever above

t1249 = RegionPlot[t1248[lon, lat] <= 0.01, {lon, -120, -90}, {lat,
30, 60}];

t2209 = ContourPlot[t1248[lon, lat], {lon, -180, 180}, {lat, -90, 90}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

t1906 = Table[rectifyCoords[i], {i, allpoly}];

t2212 = Show[{t2209, Graphics[Line[t1906]]}]

Export["/tmp/test.png", t2212, ImageSize -> {8192, 4096}]

Run["display -geometry 800x600 /tmp/test.png &"]

let's find a small coast to break it

t2209 = ContourPlot[t1248[lon, lat], {lon, -98.4375, -95.625}, 
 {lat, 27.059, 29.535}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

t2212 = Show[{t2209, Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t2212, ImageSize -> {8192, 4096}]

t1305 = Table[
 {Point[{lon, lat}], Text[ToString[{lon, lat, t1248[lon, lat]}], {lon, lat}]},
 {lon, -98.4375, -95.625, 0.1}, {lat, 27.059, 29.535, 0.1}];

t1306 = Show[{t2209, Graphics[t1305], Graphics[Line[t1906]]}]

Export["/tmp/test.png", t1306, ImageSize -> {8192, 4096}]

Run["display -geometry 800x600 /tmp/test.png &"]

t1526 = RegionPlot[t1248[lat, lon] <= 0.01/8, {lon, -98.4375, -95.625}, 
 {lat, 27.059, 29.535}];

t1527 = Show[{t1526, Graphics[t1305], Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t1527, ImageSize -> {8192, 4096}]

Run["display -geometry 800x600 /tmp/test.png &"]

t1526 = RegionPlot[t1248[lat, lon] <= 0.01/8, {lon, -97, -96}, 
 {lat, 27, 28}, ImageSize -> {8192, 4096}];

t1527 = Show[{t1526, Graphics[t1305], Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t1527, ImageSize -> {8192, 4096}]

Run["display -geometry 800x600 /tmp/test.png &"]

t1553 = ImplicitRegion[t1248[lat, lon] <= 0.01/8, {{lon, -180, 180},
{lat, -90, 90}}]

t1554 = RegionPlot[RegionMember[t1553, {lon, lat}], {lon, -98.4375, -95.625}, 
 {lat, 27.059, 29.535}];

t1601 = Show[{t1554, Graphics[Polygon[t1906]]}]

approach 20180803 starts here

t1842 = Table[Line[poly2D23D[i]], {i, allpoly}];

t1843 = RegionUnion[t1842];

t1844 = RegionDistance[t1843];

t1845 = Table[RegionDistance[i], {i, t1842}];

(* rectify coords *)

t1906 = Table[rectifyCoords[i], {i, allpoly}];

Table[f[{0,0,0}], {f, t1845}]

(* below runs fast *)

In[48]:= Table[t1845[[1]][sph2xyz[lon*Degree, lat*Degree, 1]], {lon, -180, 180, 
10}, {lat, -90, 90, 10}]                                                        
In[48]:= Timing[Table[t1845[[1]][sph2xyz[lon*Degree, lat*Degree, 1]], {lon, -180
, 180, 1}, {lat, -90, 90, 1}]];                                                 
above runs in 3 seconds

In[51]:= Timing[Table[t1845[[1]][sph2xyz[lon*Degree, lat*Degree, 1]],
{lon, -180 , 180, 0.5}, {lat, -90, 90, 0.5}]];

above is 5.73 secs

In[54]:= Timing[Table[sph2xyz[lon*Degree, lat*Degree, 1], {lon, -180 ,
180, 0.5} , {lat, -90, 90, 0.5}]];

In[55]:= %[[1]]

Out[55]= 1.08844

t2200 = Table[sph2xyz[lon*Degree, lat*Degree, 1], {lon, -180 , 180,
0.5} , {lat, -90, 90, 0.5}];

t2201 = Flatten[t2200,1];

Timing[Map[t1845[[1]], t2201]];

4.33322 seconds above

In[69]:= Timing[Map[t1845[[3]], t2201]];                                        
In[70]:= %[[1]]                                                                 
Out[70]= 3.63952

t1619 = Table[sph2xyz[lon*Degree, lat*Degree, 1], {lon, -180 , 180,
0.1} , {lat, -90, 90, 0.1}];

t1620 = Flatten[t1619, 1];

t1621 = Timing[Map[t1845[[1]], t1620]];

104.77 seconds

what if we do it one poly at a time instead of the min (will that
help?) prob not, same numbers

t1848[lon_, lat_] := 
 Min[Table[f[sph2xyz[lon*Degree, lat*Degree, 1]], {f, t1845}]];

t2209 = ContourPlot[t1848[lon, lat], {lon, -180, 180}, {lat, -90, 90}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8000, 4000}]

Export["/tmp/test.png", t2209, ImageSize -> {8000, 6000}]

Run["display -geometry 800x600 /tmp/test.png &"]

t2212 = Show[{t2209, Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t2212, ImageSize -> {8000, 6000}]

Run["display -geometry 800x600 /tmp/test.png &"]

t2218 = RegionPlot[t1848[lon, lat] <= 0.01, {lon, -180, 180}, {lat, -90, 90}];

t2219 = Show[{t2218, Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t2219, ImageSize -> {8000, 6000}]

Run["display -geometry 800x600 /tmp/test.png &"]

t2316=RegionPlot[t1848[lon, lat] <= 0.01/8, {lon, -180, 180}, {lat, -90, 90}];

t2317 = Show[{t2316, Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t2317, ImageSize -> {8000, 6000}]

Run["display -geometry 800x600 /tmp/test.png &"]




ContourPlot[t1848[lon, lat], {lon, -150, -60}, {lat, 20, 50}]

t1852 = ContourPlot[t1848[lon, lat], {lon, -150, -60}, {lat, 20, 50}, 
 ColorFunction -> Hue, Contours -> 64]

Export["/tmp/test.png", t1852, ImageSize -> {8000, 6000}]

t1856 = ContourPlot[t1848[lon, lat], {lon, -150, -60}, {lat, 20, 50}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8000, 4000}]

t1856 = ContourPlot[t1848[lon, lat], {lon, -150, -60}, {lat, 20, 50}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, PlotPoints -> 100, ImageSize -> {8000, 4000}]

t1857 = Show[{t1856, Graphics[Line[t1906]]}]

t1858 = Show[{t1856, Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t1858, ImageSize -> {8000, 4000}]

Run["display -geometry 800x600 /tmp/test.png &"]

t1916 = RegionPlot[t1848[lon, lat] <= 0.01, {lon, -150, -60}, {lat, 20, 50}];

t1917 = Show[{t1916, Graphics[Polygon[t1906]]}]

Export["/tmp/test.png", t1917, ImageSize -> {8000, 4000}]

Run["display -geometry 800x600 /tmp/test.png &"]

accuracy is an issue here... line by line?

Table[Length[i], {i, allpoly}]

325783 lines total (approx)

t2054 = allpoly[[1,1]]
t2055 = allpoly[[1,2]]

poly2D23D[Take[allpoly[[1]], 2]]

third pt is now redundant

t2057 = Line[Take[poly2D23D[Take[allpoly[[1]], 2]],2]]

t2100 = RegionDistance[t2057]

t2101 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, -180, 180}, {lat, -90, 90}]


t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, -180, 180}, {lat, -90, 90}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]

Export["/tmp/test.png", t2102, ImageSize -> {8000, 4000}]

Run["display -geometry 800x600 /tmp/test.png &"]

t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 0, 90}, {lat, 0, 90}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]


t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 45, 90}, {lat, 0, 45}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]


t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 60, 90}, {lat, 0, 30}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]


t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 55, 65}, {lat, 25, 35}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]

above works at regular size

t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01/4,
 {lon, 55, 65}, {lat, 25, 35}, AspectRatio -> 1/2, 
 ImageSize -> {8192, 4096}]

above works at regular size... but is 7 sided polygon 

t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01/8,
 {lon, 55, 65}, {lat, 25, 35}, AspectRatio -> 1/2, 
 ImageSize -> {8192, 4096}]

above fails even in bigger size

Export["/tmp/test.png", t2102, ImageSize -> {8192, 4096}]

Run["display -geometry 800x600 /tmp/test.png &"]

t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01/10,
 {lon, 55, 65}, {lat, 25, 35}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]

t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01/10,
 {lon, 55, 65}, {lat, 25, 35}, AspectRatio -> 1/2, 
 ImageSize -> {65536, 32768}]

t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 60, 61}, {lat, 29, 30}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]

above works even when 0.01 -> 0.01/10

Show[{t2102, Graphics[Line[rectifyCoords[{t2054, t2055}]]]}]

t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 45, 75}, {lat, 15, 45}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]


t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 0, 45}, {lat, 45, 90}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]


t2102 = RegionPlot[t2100[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.01,
 {lon, 29.8, 29.9}, {lat, 60.8, 60.9}, AspectRatio -> 1/2, 
 ImageSize -> {8000, 4000}]

t2108= ContourPlot[t1848[lon, lat], {lon, 60, 61}, {lat, 29, 30}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8000, 4000}]




region[n_, d_] := Module[{rdf},
 rdf = RegionDistance[Line[poly2D23D[allpolys[[n]]]]];
 Return[ImplicitRegion[rdf[sph2xyz[lon*Degree, lat*Degree, 1]] <= d,
  {{lon, -180, 180}, {lat, -90, 90}}]]
]





approach 20180728 starts here

t1017 = Table[poly2D23D[i], {i,worldPolyBiggestN[100]}];

Graphics3D[Line[t1017]]

above works

GeoGraphics[Polygon[GeoPosition[worldPolyBiggestN[100]]], 
 ImageSize -> {1600,900}]

above works, most world not antarctica covered

t1023 = RegionDistance[Line[t1017]];

above takes too long, lets do it 10 polys at a time?

t1026 = Table[poly2D23D[i], {i,worldPolyBiggestN[10]}];

Graphics3D[Line[t1026]]

above works

GeoGraphics[Polygon[GeoPosition[worldPolyBiggestN[10]]], 
 ImageSize -> {1600,900}]

above works quite a bit of world covered

t1027 = RegionDistance[Line[t1026]];

t1027 = RegionDistance[Line[t1026]];                                    

t1027[{0,0,0}]

above ALSO takes too long, so it's one poly at a time <h>(maybe
Valerie Bertanelli will show up)</h>

n = 1;

t1030 = worldPolyList[[worldPolyListAreaSorted[[n,1]]]];

t1031 = poly2D23D[t1030];

Graphics3D[Line[t1031]]

above works

GeoGraphics[Polygon[GeoPosition[t1030]], ImageSize -> {1600,900}]

above works

t1032 = RegionDistance[Line[t1031]];

t1032[{0,0,0}]

yields 0.999962 but works

t1035 = ContourPlot[t1032[sph2xyz[lon*Degree, lat*Degree, 1]] == 0.0156, 
 {lon, -180, 180}, {lat, -90, 90}]

Show[{t1035, Graphics[Line[rectifyCoords[t1030]]]}]

RegionPlot[t1032[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.0156, 
 {lon, -180, 180}, {lat, -90, 90}]

t1044 = ImplicitRegion[t1032[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.0156,  
 {{lon, -180, 180}, {lat, -90, 90}}];

t1047 = 
 RegionPlot[RegionMember[t1044, {lon, lat}], {lon, -180, 180}, {lat, -90, 90}];

t1048 = 
 RegionPlot[RegionMember[t1044, {lon, lat}], {lon, 0, 180}, {lat, 40, 80}];

Show[{t1048, Graphics[Line[rectifyCoords[t1030]]]}]

t1050 = DiscretizeRegion[t1044];

above fails, region is multipolygonal

a gap near 120-150 and 45-55 hmmm

t1048 = 
 RegionPlot[RegionMember[t1044, {lon, lat}], {lon, 120, 150}, {lat, 45, 55}];

t1049 = Show[{t1048, Graphics[Line[rectifyCoords[t1030]]]}]

Export["/tmp/temp.png", t1049, ImageSize -> {8000, 6000}]

t1048 = 
 RegionPlot[RegionMember[t1044, {lon, lat}], {lon, 120, 151}, {lat, 45, 46}];

Show[{t1048, Graphics[Polygon[rectifyCoords[t1030]]]}]

subproblem 7/30/18: why are polygons so twisty?











world1834 = world[[1,1]];

worldsph = Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&,world1834, {2,2}];

worldsph2 = Map[Line, worldsph];

worldreg = Apply[RegionUnion, worldsph2];

worlddist = RegionDistance[worldreg];

lower res but worksable?

world2 = CountryData["World", "Polygon"];

world1834 = world2[[1,1]];

worldsph = Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&,world1834, {2,2}];

worldsph2 = Map[Line, worldsph];

worldreg = Apply[RegionUnion, worldsph2];

worlddist = RegionDistance[worldreg];

ignoring smaller islands ... for now

world = CountryData["World", "FullPolygon"];

GeoArea[Polygon[GeoPosition[world[[1,1,6]]]]] for example

t1908= Table[{i, 
 UnitConvert[GeoArea[Polygon[GeoPosition[
 world[[1,1,i]]]]]][[1]]},
 {i, 1, Length[world[[1,1]]]}];

t1916 = Sort[t1908, #1[[2]] > #2[[2]] &];

t2018 = Entity["Country", "World"]["Polygon"];

Transpose[Flatten[t2018[[1,1]], 1]]

Min[Transpose[Flatten[t2018[[1,1]], 1]] [[1]]]

confirms antarctica is not included

t2019= Table[{i, 
 UnitConvert[GeoArea[Polygon[GeoPosition[
 t2018[[1,1,i]]]]]][[1]]},
 {i, 1, Length[t2018[[1,1]]]}];

t2020 = Sort[t2019, #1[[2]] > #2[[2]] &];

t1910 = t2018[[1,1,1612]];

4310 length above

t1911 = Graphics[Line[Take[t1910,1000]]]

t1912 = Export["/tmp/temp.png", t1911, ImageSize -> {8000, 6000}]





ListLogPlot[Transpose[t1916][[2]]]

Subject: Itsy-Bitsy Teeny-Weeny Little Polka Dot Island in CountryData

I'm probably misunderstanding something, but:

temp = CountryData["World", "FullPolygon"][[1,1,15737]]

{{2.08158, 109.645}, {2.08158, 109.645}, {2.08158, 109.645}}

GeoArea[Polygon[GeoPosition[temp]]]

0.0000444087 meters squared

As nearly as I can tell, Mathematica is listing an island that's less than 1 cm^2, which is probably an error. Notes:

  - `CountryData["World", "FullPolygon"]` is a one element list that itself contains only a one-element list, so it's not like I'm going too deep.

  - Of the 24967 polygons total, 8173 are less than 1 km^2 in size, and 248 are less than 100 m^2 (the size of a small room).

This sort of thing is particularly annoying given https://mathematica.stackexchange.com/questions/178833/area-of-countries-given-by-geoboundaries-does-not-equal-area-in-database where I show the total land area of Mathematica's polygons is only about 92% of the actual land area.

Am I missing something or is this just bad data?



. For example, the largest entry, `CountryData["World", "FullPolygon"][[1,1,19972]]` has an area of `1.65199*10^7 kilometers squared`, 







In[17]:= temp = Map[f[#1[[1]],#1[[2]]] &, world1834, 2];                        


sphtemp[{x_,y_}] = sph2xyz[y*Degree, x*Degree, 1];

t1844 = Table[world1834[[i,j]], {i, 1, Length[world1834]}
 {j, 1, Length[world1834[[i]]]}];


worlsph = Map[sphtemp, world1834, 2];

worldsph = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, world1834, 2];

worldsph2 = Map[Line[#] &, worldsph];




world2 = Polygon[world[[1,1]]];

world1715 = Polygon[world[[1,1,1]]]

RegionMember[world1715, {x,y}]

the above works!

ContourPlot[RegionDistance[world1715, {x,y}], {x,-180, 180}, {y,-180,180}]

same thing w usa now?

usa = CountryData["UnitedStates", "FullPolygon"];

usa2 = Polygon[usa[[1,1,1]]]

usa3 = RegionDistance[usa2]

ContourPlot[usa3[{x,y}], {x,0,90}, {y,-180,0}, PlotPoints -> 2]


ContourPlot[usa3[{x,y}], {x,24,50}, {y,-125,-66}, PlotPoints -> 2]

memoize inclusion

member1803[x_, y_] := member1803[x,y] = RegionMember[usa2, {x,y}];

t1802 = ImplicitRegion[member1803[x,y], {x,y,z}];

can we do it with lines?

usaline = Line[usa[[1,1,1]]];

ContourPlot[RegionDistance[usaline,{x,y}], {x,24,50}, {y,-125,-66}]

t1821 = ImplicitRegion[
 RegionMember[usaline, {ArcTan[x, y]/Degree, ArcTan[Sqrt[x^2 + y^2]]/Degree}],
 {x,y,z}]

t1822 = RegionDistance[t1821];

usa1sph = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, usa[[1,1,1]]];

usa1828 = Line[usa1sph]

usa1829 = RegionDistance[usa1828];

ContourPlot[usa1829[sph2xyz[th, ph, 1]], {th, -Pi, Pi}, {ph, -Pi/2, Pi/2}]

ContourPlot[usa1829[sph2xyz[th, ph, 1]], {th, -Pi, Pi}, {ph, -Pi/2, Pi/2},
 ColorFunction -> Hue, Contours -> 64]








t1717 = ImplicitRegion[RegionMember[world1715, {ArcTan[x, y]/Degree,
ArcTan[Sqrt[x^2 + y^2]/Degree]}] && x^2 + y^2 + z^2 == 1, {x,y,z}];

t1728 = ImplicitRegion[x^2 + y^2 + z^2 == 1, {x,y,z}]

t1733 = RegionDistance[t1728]

ContourPlot3D[t1733[{x,y,z}], {x,-1,1}, {y,-1,1}, {z,-1,1}]

t1744 = ImplicitRegion[RegionMember[world1715, {x,y}], {x,y,z}]







RegionMember[world2, {x,y}]

worldsph = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, world[[1,1]], 2];

worldsphreg = Polygon[worldsph];

worldsph1 = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, world[[1,1,1]], 1];

testing w/ just 1 poly

t1451 = Polygon[world[[1,1,1]]]



t1452 = TransformedRegion[t1451, 
 sph2xyz[#[[1]]*Degree, #[[2]]*Degree, 1] &];



test1251 = TransformedRegion[world2, 
 sph2xyz[#[[1]]*Degree, #[[2]]*Degree, 1] &];

correct form is below

test1251 = TransformedRegion[world2, 
 sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &];


t1311 = Table[sph2xyz[i[[1]]*Degree, i[[2]]*Degree, 1], {i, world[[1,1,7]]}]

t1313 = ConicHullRegion[t1311]

t1327 = Table[i/i[[3]], {i, t1311}]

Prepend[Append[t1311, {0,0,0}], {0,0,0}]

test w/ USA

usa = CountryData["UnitedStates", "FullPolygon"];

usa1617 = Polygon[usa[[1,1]]];

usa1623 = RegionMember[usa1617]

RegionPlot[usa1623[{y,x}], {y,-180,180}, {x,-90,90}]


usa2 = Table[sph2xyz[i[[2]]*Degree, i[[1]]*Degree, 1], {i, usa[[1,1,1]]}];

Graphics3D[Polygon[usa2]]

usa3 = Polygon[usa2];

RegionPlot3D[RegionMember[usa3, {x,y,z}], {x,-1,1}, {y,-1,1}, {z,-1,1}]

usa4 = DiscretizeRegion[usa3];

RegionPlot3D[RegionMember[usa4, {x,y,z}], {x,-1,1}, {y,-1,1}, {z,-1,1}]

t1501 = TransformedRegion[usa3, 
 {Indexed[#,1], Indexed[#,2], Indexed[#,3]}/
 Norm[{Indexed[#,1], Indexed[#,2], Indexed[#,3]}] &];

RegionMember[t1501]

RegionPlot[RegionMember[usa4, {x,y,z}], {x,-1,1}, {y,-1,1}, {z,-1,1}]



mindist = RegionDistance[Polygon[usa2], {0,0,0}]

usa3 = usa2/mindist*2;

Graphics3D[{Sphere[{0,0,0}], Polygon[usa3]}];

usa4 = Prepend[Append[usa3, {0,0,0}], {0,0,0}];

Graphics3D[{Sphere[{0,0,0}], Polygon[usa4]}];

usa5 = RegionIntersection[Sphere[{0,0,0}], Polygon[usa4]]

RegionPlot3D[RegionMember[usa5, {x,y,z}], {x,-1,1}, {y,-1,1}, {z,-1,1}]

Graphics3D[{Polygon[usa4]}]
Graphics3D[{Polygon[usa4], Sphere[{0,0,0}]}]

usa1440 = Polygon[usa[[1,1,1]]];

usa1435 = TransformedRegion[usa1440, 
 sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &];









ListPlot[world[[1,1,5]]]

In[14]:= RegionQ[Polygon[world[[1,1]]]]                                         
t2333 = RegionIntersection[ Polygon[world[[1,1]]],
 Polygon[{ {30, -180}, {30, 180}, {40, 180}, {40, -180}}]];


countries = CountryData[];

CountryData[countries[[7]], "LandArea"]

CountryData[countries[[7]], "FullPolygon"]

t2355 = Table[{
 CountryData[i, "Name"], 
 UnitConvert[CountryData[i, "Area"]][[1]], 
 UnitConvert[GeoArea[CountryData[i, "FullPolygon"]]][[1]]
}, 
 {i, countries}];

t2356 = Table[Join[i, {i[[3]]/i[[2]]}], {i, t2355}];

t0001 = Sort[t2356, #1[[4]] < #2[[4]] &];

using the 55M JPEG I downloaded w/ 1km resolution

ImageTake[im, {10000,10001}]

im = Import["/home/user/Downloads/world_shaded_43k.jpg"];

imdata = ImageData[im];

imdata2 = Flatten[imdata,1];

write to file testing (1 line per list item)

str = OpenWrite["/tmp/imdata2.txt"];
Table[WriteLine[str, ToString[i]], {i,imdata2}];
Close[str];

str = OpenWrite["/tmp/test2.txt"]
Table[WriteLine[str, Prime[i]], {i,1,10}];
Close[str];

imdata3 = Gather[imdata2];



11,10,50 is ocean color BUT 11,9,50 may be too yikes

In[17]:= DeleteDuplicates[imdata[[5]]]                                          

Out[17]= {{0.0431373, 0.0392157, 0.196078}}

In[26]:= Length[test]                                                           

Out[26]= 933120000

test2 = DeleteDuplicates[test];

In[28]:= Length[test2]                                                          

Out[28]= 798798

test3 = Gather[test];

TODO: what zoom level do I need to get this from googlemaps/OSM

appears to be level 7









worldbm = BoundaryMesh[world[[1,1]]];

below works:

worldbm = BoundaryDiscretizeRegion[Polygon[world[[1,1,5]]]]

this crashes mathematica:

In[2]:= BoundaryDiscretizeRegion[Polygon[world[[1,1]]]]                         

below works

RegionPlot[worldbm]

t1829 = Table[BoundaryDiscretizeRegion[Polygon[i]], {i, world[[1,1]]}];

t1834 = Map[RegionPlot, t1829]

https://mathematica.stackexchange.com/questions/139208/how-to-calculate-the-maximal-geodistance-and-traveldistance-in-a-geo-region

worlddg = BoundaryDiscretizeGraphics[CountryData["World", "Polygon"]]

usadg = BoundaryDiscretizeGraphics[CountryData["UnitedStates", "Polygon"]]

usa = CountryData["UnitedStates", "Polygon"];

ListPlot[usa[[1,1]]];


ListPlot[CountryData["UnitedStates","Polygon"][[1,1]]]

NMinimize[GeoDistance[{1,2}, x], Element[x, Polygon[usa[[1,1]]]]]

Polygon[usa[[1,1]]]

NMinimize[GeoDistance[{1,2}, x], Element[x, Polygon[usa[[1,1]]]]]

NMinimize[GeoDistance[{1,2}, x], Element[x, BoundaryMesh[Polygon[usa[[1,1]]]]]]


intheusa[x_] = Element[x, Polygon[usa[[1,1]]]]

RegionMember[Polygon[usa[[1,1]]], {1,2}]

RegionMember[Polygon[{{0, 0}, {1, 0}, {0, 1}}], {1/3, 1/3}]

RegionMember[Polygon[usa[[1,1,1]]], {1,2}]

NMinimize[GeoDistance[{1,2}, x], RegionMember[Polygon[usa[[1,1,1]]], x]]

NMinimize[GeoDistance[{1,2}, x], Element[x, Polygon[usa[[1,1,1]]]]]

geod[x_,y_] := GeoDistance[x,y];

NMinimize[geod[{1,2}, x], Element[x, Polygon[usa[[1,1,1]]]]]

NMinimize[Norm[{1,2}, x], Element[x, Polygon[usa[[1,1,1]]]]]

NMinimize[Norm[{1,2}, {x,y}], Element[{x,y}, Polygon[usa[[1,1,1]]]]]

test cases here

p = RegularPolygon[5]

NMinimize[Norm[{1,2}-{x,y}], Element[{x,y}, p]]

above works, below doesnt

NMinimize[Norm[{1,2}-x], Element[x, p]]

dist[x_,y_] := dist[x,y] = NMinimize[Norm[{x,y}-{a,b}], Element[{a,b}, 
 RegularPolygon[5]]][[1]]

ContourPlot[dist[x,y],{x,-1,1},{y,-1,1}]

regiondistance is the magic

ContourPlot[RegionDistance[RegularPolygon[5], {x,y}], {x,-2,2},
{y,-2,2}, PlotLegends -> True, ColorFunction -> Hue, Contours -> 64,
ContourLines -> False]

ContourPlot[RegionDistance[RegularPolygon[5], {x,y}], {x,-90,90},
{y,-90,90}, PlotLegends -> True, ColorFunction -> Hue, Contours -> 64,
ContourLines -> False]

RegionDistance[Sphere[0,1], {0,4,5}]

usa = CountryData["UnitedStates", "Polygon"]

usapoly = Polygon[CountryData["UnitedStates", "Polygon"][[1,1,1]]];

discs = Table[GeoDisk[i, Quantity[100, "km"]], {i, usapoly[[1]]}];

t1844 = GeoDisk[{35.05, -106.5}, Quantity[100, "km"]]

GeoGraphics[{RGBColor["Red"], Opacity[1, "Red"], t1844}];
showit;

GeoGraphics[{GeoStyling[None], t1844}];
GeoGraphics[{GeoStyling[None], discs}, ImageSize -> {8000,6000}];
Export["/tmp/test.png", %, ImageSize -> {8000,6000}];
showit;

GeoServer::maxtl: Number of requested tiles, 1904, is too large.

GeoGraphics::wdata: 
   Unable to download data for ranges {{18.2462, 55.553}, {-143.061, -48.7063}}
     and zoom level 8 from the Wolfram geo server.



ContourPlot[RegionDistance[usapoly, {x,y}], {x,-90,90},
{y,-90,90}, PlotLegends -> True, ColorFunction -> Hue, Contours -> 64,
ContourLines -> False]

usadist = RegionDistance[Polygon[CountryData["UnitedStates",
"Polygon"][[1,1,1]]]];

ContourPlot[usadist[{x,y}], {x,-180,180},
{y,-180,180}, PlotLegends -> True, ColorFunction -> Hue, Contours -> 64,
ContourLines -> False]


usa[[1,1,1]]

usasph = Table[sph2xyz[i[[2]]*Degree, i[[1]]*Degree, 1], {i, usa[[1,1,1]]}]

Graphics3D[Polygon[usasph]]

usasphdist = RegionDistance[Polygon[usasph]];

dist[long_, lat_] :=
 ArcSin[usasphdist[sph2xyz[long*Degree, lat*Degree, 1]]/2]/Pi;


ContourPlot[dist[long,lat], {long, -180, 180}, {lat, -90, 90}, 
 PlotLegends -> True, ColorFunction -> Hue, Contours -> 64,
 ContourLines -> False]





ContourPlot3D[usasphdist[{x,y,z}], {x, -1, 1}, {y, -1, 1}, {z, -1, 1},
PlotLegends -> True, ColorFunction -> Hue, Contours -> 64]



In[43]:= ConicHullRegion[Table[sph2xyz[i[[2]]*Degree, i[[1]]*Degree, 1], {i, usa
[[1,1,1]]}]]                                                                    
Graphics3D[Polygon[usasph]]

Graphics3D[{Polygon[usasph], Sphere[{0,0,0}]}]

world = CountryData["World", "Polygon"];

worldsph = Table[sph2xyz[i[[2]]*Degree, i[[1]]*Degree, 1], {i, usa[[1,1,1]]}]

worldsph = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, world[[1,1]], 2];

worldsph = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, world[[1,1]], 2];

world2 = Map[Polygon[#] &, worldsph, 1]

Graphics3D[{world2, Sphere[{0,0,0}]}]

Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, world[[1,1]], 2]

In[173]:= Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, world[[1,1,5]]]       
t2112 = Table[Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, i], 
 {i, world[[1,1]]}];

Graphics3D[Polygon[t2112]]

Graphics3D[{Polygon[t2112], Sphere[{0,0,0}]}]

Graphics3D[{Polygon[t2112], RGBColor[{0,0,1}], Sphere[{0,0,0}]}]

worlddist = RegionDistance[Polygon[t2112]];

ContourPlot3D[worlddist[{x,y,z}], {x, -1, 1}, {y, -1, 1}, {z, -1, 1},
PlotLegends -> True, ColorFunction -> Hue, Contours -> 64]


usasphdist[{x,y,z}], {x, -1, 1}, {y, -1, 1}, {z, -1, 1},
PlotLegends -> True, ColorFunction -> Hue, Contours -> 64]

geobounds

GeoGraphics[GeoCircle[{0, 0}, 500000]]

flatworld = Flatten[world[[1,1]],1];

worldd[lon_, lat_] = 2*ArcSin[
 worlddist[sph2xyz[lon*Degree, lat*Degree, 1]]/2
 ]*rad[0]

ContourPlot[worldd[long,lat], {long, -180, 180}, {lat, -90, 90}, 
 PlotLegends -> True, ColorFunction -> Hue, Contours -> 64,
 ContourLines -> False]

useful tests:

a = Polygon[{{-90, -45}, {-90, 45}, {90, 45}, {90, -45}}]

b = Polygon[GeoPosition[{{-90, -45}, {-90, 45}, {90, 45}, {90, -45}}]]

GeoArea[b] // InputForm

Out[39]//InputForm= Quantity[1.27516405429623*^8, "Kilometers"^2]

In[42]:= CountryData["World", "Area"]/GeoArea[b]                                

Out[42]= 4.00005

so, yes, it works

<< /home/user/20180724/land-polygons-complete-4326/land_polygons.m;

ugly hack to avoid the missing poly

poly1 = Table[poly[i], {i,0,148985}];
poly2 = Table[poly[i], {i,148987,625999}];

poly3 = Join[poly1,poly2];

poly4 = GeoPosition[poly3];

poly5 = Polygon[poly4];

GeoArea[poly5]

Quantity[9.845573885094109*^7, "Kilometers"^2]

Quantity[1.4894*^8, "Kilometers"^2] is accepted value

only .661043


In[2]:= Length[DownValues[poly]]                                                

Out[2]= 148986

ok, poly[148985] defined, but poly[148986] is not

Syntax::sntx: Invalid syntax in or before "13.0678091}),"
                                                       ^
     (line 9767682 of
     "/home/user/20180724/land-polygons-complete-4326/temp2.txt").

{80.2906779,
13.0678091}),
({48.0258669,

spurios parens?

imdata2.txt freq occurring pixels

596233046 {0.0431373, 0.0392157, 0.196078}

breaking into smaller images for review

world_shaded_43k.jpg JPEG 43200x21600 43200x21600+0+0 8-bit DirectClass 55.3MB 0.000u 0:00.000

testing:

convert -crop 1600x800+0+0 world_shaded_43k.jpg test.jpg

working thru https://mathematica.stackexchange.com/questions/78705/plot-a-partition-of-the-sphere-given-vertices-of-polygons

origin = {0, 0, 0};
points = {
  {-0.9207, -0.3896, 0.0091},
  {-0.8272,  0.5077, -0.2399},
  {0.2544, -0.3511, 0.901},
  {0.351, 0.6527, 0.6712},
  {0.5436, -0.6326, -0.5513},
  {0.6016, 0.2317, -0.7643}
};
fs = {{1, 3, 5}, {1, 2, 4, 3}, {1, 2, 6, 5}, {3, 4, 6, 5}, {2, 4, 6}};
faces = points[[#]] & /@ fs;
colours = RandomColor[5];

    my($c1) = cos($x)*cos($y)*cos($u)*cos($v);
    my($c2) = cos($x)*sin($y)*cos($u)*sin($v);
    my($c3) = sin($x)*sin($u);
    return ($EARTH_RADIUS*acos($c1+$c2+$c3));

c1 = Cos[x]*Cos[y]*Cos[u]*Cos[v];
c2 = Cos[x]*Sin[y]*Cos[u]*Sin[v];
c3 = Sin[x]*Sin[u];
ArcCos[c1+c2+c3];

conds = {0 <= x <= 2*Pi, 0 <= y <= 2*Pi, 0 <= u <= 2*Pi, 0 <= v <= 2*Pi};

FullSimplify[ArcCos[c1+c2+c3], conds]

order below is lat/lon from http://williams.best.vwh.net/avform.htm

gcd[x_, y_, u_, v_] = ArcCos[Cos[u]*Cos[x]*Cos[v - y] + Sin[u]*Sin[x]]

result is in earth radii

Solve[gcd[lat1, lon1, lat2, lon2] == c, Reals]

Solve[gcd[lat1, lon1, lat2, lon2] == c, lon2, Reals]



conds = {-Pi/2 <= lat1 <= Pi/2, -Pi/2 <= lat2 <= Pi/2,
         -Pi <= lon1 <= Pi, -Pi <= lon2 <= Pi,
         0 <= c <= 2*Pi};

moreconds = { 0 <= lat1 <= Pi/2, 0 <= lat2 <= Pi/2, 
              0 <= lon1 <= Pi, 0 <= lon2 <= Pi,
              0 <= c <= 2*Pi};

FullSimplify[Solve[gcd[lat1, lon1, lat2, lon2] == c, lon2, Reals],conds]

FullSimplify[Solve[gcd[lat1, lon1, lat2, lon2] == c, lon2, Reals],moreconds]

GeoBoundsRegion = latitude/longitude rectangle

yet another try on 27 Jul 2018, using largest areas first

world = CountryData["World", "FullPolygon"];

world2 = world[[1,1]];

worldpoly = Table[{i, 
 UnitConvert[GeoArea[Polygon[GeoPosition[world2[[i]]]]]][[1]]}, 
 {i, 1, Length[world2]}];

worldpoly2 = Sort[worldpoly, #1[[2]] > #2[[2]] &];

worlds worst way to reverse 2D coords

revcoords[list_] := Transpose[Reverse[Transpose[list]]]

let's plot 10 largest

t1332 = Transpose[Take[worldpoly2, 10]][[1]]

t1333 = Table[Polygon[revcoords[world2[[i]]]], {i, t1332}];

poly2d2poly3d[list_] := 
 Line[Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&, list]]

t1343 = poly2d2poly3d[world2[[19972]]];

RegionQ[t1343]

RegionDistance[t1343, {0,0,0}]

not quite on the unit sphere but 0.999962

t1948 = RegionDistance[t1343]

ContourPlot[t1948[sph2xyz[th*Degree,ph*Degree,1]],
 {th, -180, 180}, {ph, -90, 90}]

ContourPlot[t1948[sph2xyz[th*Degree,ph*Degree,1]],
 {th, -180, 180}, {ph, -90, 90}, ColorFunction -> Hue, Contours -> 64,
 ContourLines -> False]

ContourPlot[t1948[sph2xyz[th*Degree,ph*Degree,1]],
 {th, -180, 180}, {ph, -90, 90}, ColorFunction -> Hue, Contours -> 256,
 ContourLines -> False]


ContourPlot[t1948[sph2xyz[th*Degree,ph*Degree,1]] == 0,
 {th, -180, 180}, {ph, -90, 90}, ColorFunction -> Hue, Contours -> 256,
 ContourLines -> False]

ContourPlot[t1948[sph2xyz[th*Degree,ph*Degree,1]] == 0,
 {th, -180, 180}, {ph, -90, 90}]

ContourPlot[t1948[sph2xyz[th*Degree,ph*Degree,1]] == 0.01,
 {th, -180, 180}, {ph, -90, 90}]

ContourPlot3D[t1948[{x,y,z}], {x,-1,1}, {y,-1,1}, {z,-1,1}]

Apply[Take[world2, #] &, Transpose[Take[worldpoly2, 10]][[1]]]

Polygon[Apply[revcoords[world2[[#]]]] &, 
 Transpose[Take[worldpoly2, 10]][[1]]]];

Polygon[Apply[revcoords[Take[world2, #]] &,
 Transpose[Take[worldpoly2, 10]][[1]]]];

Apply[revcoords[world2[[#]]], Transpose[Take[worldpoly2, 10]][[1]]]

GeoGraphics[Polygon[Transpose[Reverse[Transpose[world2[[19972]]]]]]]

Transpose[worldpoly2][[2]]

an approach that definitely doesn't work, but is interesting?

Table[GeoDistance[{0,0}, x], {x, world2[[1]]}]

t2049[y_] := Min[Table[GeoDistance[y, x], {x, world2[[19972]]}]]

t2058[x_,y_,z_] = {x,y,z}/Norm[{x,y,z}];

t2059 = TransformedRegion[t1343, t2058]

Drop[Table[{Cos[theta], Sin[theta]}, {theta, 0, 360*Degree, 360*Degree/5}],1]

an ugly pentagon

t2109 = 90*N[Drop[
 Table[{Cos[theta], Sin[theta]}, {theta, 0, 360*Degree,360*Degree/5}],
1]]

poly2d2poly3d[t2109]

RegionDistance[poly2d2poly3d[t2109], {0,0,0}]

t2115[x_] = FractionalPart[x]*t2109[[Floor[x]]] +
 1-FractionalPart[x]*t2109[[Floor[x]+1]]

t2115[x_] := Module[{}, 
 FractionalPart[x]*t2109[[Floor[x]]] +
 (1-FractionalPart[x])*t2109[[Floor[x]+1]]
];

ParametricPlot[t2115[x],{x,1,5}]                                      

t2122[x_] := Module[{}, 
 Append[Degree*(FractionalPart[x]*t2109[[Floor[x]]] +
 (1-FractionalPart[x])*t2109[[Floor[x]+1]]), 1]
];

t2124[x_] := Module[{}, 
 sph2xyz[Append[Degree*(FractionalPart[x]*t2109[[Floor[x]]] +
 (1-FractionalPart[x])*t2109[[Floor[x]+1]]), 1]]
];

GeoNearest[Entity["Country"], {0,0}]

ImplicitRegion[GeoDistance[{lat,lon}, {0,0}] < 100000, {lat, lon}]

bd = DiscretizeRegion[RegionBoundary[poly], MaxCellMeasure -> {1 -> .1}];

bd = DiscretizeRegion[RegionBoundary[Polygon[world2[[1]]]], 
 MaxCellMeasure -> {1 -> .1}]

MeshCoordinates[bd]

bd = DiscretizeRegion[Line[world2[[1]]],  MaxCellMeasure -> {1 -> .1}]

MeshCoordinates[bd]

bd = DiscretizeRegion[Line[world2[[1]]]]

t2344 = poly2d2poly3d[world2[[19972]]];

t2345 = DiscretizeRegion[poly2d2poly3d[world2[[19972]]],
 MaxCellMeasure -> {"Length" -> .001}];

MeshCoordinates[t2345]

t2347 = DiscretizeRegion[poly2d2poly3d[world2[[19972]]],
 MaxCellMeasure -> {"Length" -> 10^-6}];

Length[world2[[19972]]]

t2349 = DiscretizeRegion[Line[world2[[19972]]], MaxCellMeasure -> {"Length" ->
10^-3}]

t2358 = poly2d2poly3d[MeshCoordinates[t2349]];                        

poly2d2poly3d[list_] := 
 Line[Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&, 
 Append[list, list[[1]]]]]

t2358 = DiscretizeRegion[Line[world2[[19972]]], MaxCellMeasure -> {"Length" ->
10^-2}]

t2359 = poly2d2poly3d[MeshCoordinates[t2358]];                        

map1[lat_, lon_] = {lon*Cos[lat], lat}


map1[lat1,lon1] - map1[lat2,lon2]

t0022 = Table[poly2d2poly3d[i], {i,world2}];

poly2d2poly3d[list_] := 
Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&, 
 Append[list, list[[1]]]]

t0024 = Table[poly2d2poly3d[i], {i,world2}];

Graphics3D[Line[t0024]]

t0026 = RegionDistance[Line[t0024]];

approach on 30 Jul 2018 using entity data

t2214 = Entity["Country", "World"]["Polygon"];
t2215 = Entity["Country", "Antarctica"]["Polygon"];

GeoGraphics[{t2214,2215}]

1851 + 25 polygons

t2219 = Join[t2214[[1,1]],t2215[[1,1]],1];

t2221 = Map[poly2D23D, t2219];

t2024 = Table[RegionDistance[Line[i]], {i, t2221}];

Table[f[{0,0,0}]-1, {f, t2024}]

Table[f[sph2xyz[{25*Degree, 5*Degree,1}]], {f, t2024}]

t2029[lon_, lat_] := 
 Min[Table[f[sph2xyz[lon*Degree, lat*Degree, 1]], {f, t2024}]];

ContourPlot[t2029[lon,lat], {lon, -180, 180}, {lat, -90, 90}]

f[t_] = {x1, y1, z1} + t*{x2-x1, y2-y1, z2-z1}

{x3, y3, z3} - f[t]




Graphics3D[Polygon[t2221]]

the above works!

Graphics3D[Line[t2221]]

the above also works

RegionQ[Line[t2221]]

t2223 = RegionDistance[Polygon[t2221]];

above works, but gets too far from surface

t2224 = RegionDistance[Line[t2221]];

above is too slow

polygon by polygon?

t2227 = t2219[[1]];

t2227 is any poly

n = 1;

t2228 = RegionDistance[Line[poly2D23D[t2219[[n]]]]];

ContourPlot[t2228[sph2xyz[lon*Degree, lat*Degree, 1]], {lon, -180,
180}, {lat, -90, 90}, ColorFunction -> Hue, ContourLines -> False,
Contours -> 16];

t2229 = ImplicitRegion[t2228[sph2xyz[lon*Degree, lat*Degree, 1]] <= 0.0156,
  {{lon, -180, 180}, {lat, -90, 90}}];

RegionPlot[RegionMember[t2229,{lon,lat}], {lon, -180, 180}, {lat, -90, 90}]

general function for given polygon and distance (need to clean stuff
up, but still)

region[n_, d_] := Module[{rdf},
 rdf = RegionDistance[Line[poly2D23D[t2219[[n]]]]];
 Return[ImplicitRegion[rdf[sph2xyz[lon*Degree, lat*Degree, 1]] <= d,
  {{lon, -180, 180}, {lat, -90, 90}}]]
]

t2243 = Table[region[n, 0.1], {n,1,200}];

t2244 = RegionUnion[t2243];

RegionPlot[RegionMember[t2244,{lon,lat}], {lon, -180, 180}, {lat, -90, 90}]
 
t2247 = Table[region[n, 0.1], {n,1,Length[t2219]}];

02 Aug 2018 using true geodesics (assuming spherical)

three d geodesic from p to q, assumed to be three 3d points, parameter t

geoDesic3D[p_, q_, t_] = (p + t*(q-p))/Norm[p+ t*(q-p)];

regLine[p_, q_, t_] = p+t*(q-p)

Norm[sph2xyz[lon3, lat3, 1] -
 regLine[sph2xyz[lon1, lat1, 1], sph2xyz[lon2, lat2, 1], t]]

conds = {-Pi < lon1 < Pi, -Pi < lon2 < Pi, -Pi < lon3 < Pi,
         -Pi/2 < lat1 < Pi/2, -Pi/2 < lat2 < Pi/2, -Pi/2 < lat3 < Pi/2, 
        0 < t < 1};

FullSimplify[geoDesic3D[sph2xyz[th1, ph1, 1], sph2xyz[th2, ph2, 1], t], conds]




geoDesic3D[sph2xyz[{0,0,1}], sph2xyz[{25*Degree, 55*Degree,1}], t]

t1935 = ParametricPlot3D[
 geoDesic3D[sph2xyz[{0,0,1}], sph2xyz[{25*Degree, 55*Degree,1}], t],
 {t,0,1}]

t1936 = Graphics3D[{Sphere[{0,0,0}]}];

Show[{t1936, t1935}]

conds = {-Pi < lon1 < Pi, -Pi < lon2 < Pi, -Pi < lon3 < Pi,
         -Pi/2 < lat1 < Pi/2, -Pi/2 < lat2 < Pi/2, -Pi/2 < lat3 < Pi/2, 
        0 < t < 1};

geoDesic3D[sph2xyz[{lon1, lat1, 1}], sph2xyz[{lon2, lat2, 1}], t]

t1946[t_] = Simplify[VectorAngle[
 geoDesic3D[sph2xyz[{lon1, lat1, 1}], sph2xyz[{lon2, lat2, 1}], t],
 sph2xyz[{lon3, lat3, 1}]], conds]

Solve[GeoDistance[{35, -106}, {x,y}] == Quantity[1000, "km"], {x,y}]

GeoDesic3D[sph2xyz[{-110*Degree, 40*Degree, 1}],
           sph2xyz[{-90*Degree, 30*Degree, 1}], t]

VectorAngle[
 geoDesic3D[sph2xyz[{-110*Degree, 40*Degree, 1}],
           sph2xyz[{-90*Degree, 30*Degree, 1}], t],
 sph2xyz[-106.5*Degree, 35*Degree, 1]]

t2004 = ParametricRegion[
GeoDesic3D[sph2xyz[{-110*Degree, 40*Degree, 1}],
           sph2xyz[{-90*Degree, 30*Degree, 1}], t],
{t,0,1}];

t2004 = ParametricRegion[
geoDesic3D[sph2xyz[{-110*Degree, 40*Degree, 1}],
           sph2xyz[{-90*Degree, 30*Degree, 1}], t],
{{t,0,1}}];

t2009 = RegionDistance[t2004];

03 aug 2018 comparing country entity to world entity

t1727 = Entity["Country", "UnitedStates"]["Polygon"];

counts = Entity["Country"];

t1734 = EntityList["Country"];

t1734[[1]]["Polygon"]

In[40]:= Length[t1734[[1]]["Polygon"] ]                                         

Out[40]= 1

In[41]:= Length[t1734[[1]]["Polygon"][[1]]]                                     

Out[41]= 1

In[42]:= Length[t1734[[1]]["Polygon"][[1,1]]]                                   
t1734[[1]]["Polygon"][[1,1,1]]

GeoArea[Polygon[GeoPosition[t1734[[2]]["Polygon"][[1,1,1]]]]]

TODO: country data might be better

using vector angles to find min dist to geodesic


f[t_] = {x1, y1, z1} + t*{x2-x1, y2-y1, z2-z1}

dot product div by norm, p3 is on sphere

dp = f[t].{x3,y3,z3}/Norm[f[t]]

dp2[t_] = (f[t].{x3,y3,z3}/Norm[f[t]])^2

D[dp2[t], t]

Solve[D[dp2[t], t] == 0, t]

sol = (x1*x3 + y1*y3 + z1*z3)/(x1*x3 - x2*x3 + y1*y3 - y2*y3 + z1*z3 - z2*z3)

dp2[sol]

g[t_] = t*{1,0,0}

dp2[t_] = (g[t].{x3,y3,z3}/Norm[g[t]])^2

lets use some real pts to figure this out

pt1 = {0.848898, 0.108727, 0.517253};

pt2 = {0.589858, 0.0921671, 0.80223};

t1417[t_] = pt1 + t*(pt2-pt1);

pt3 = {0.600849, 0.0211775, 0.799082};

conds = {Element[t, Reals]}

Plot[t1417[t].pt3, {t,0,1}]

Plot[t1417[t].pt3/Norm[t1417[t]], {t,0,1}]

dp2[t_] = Simplify[(t1417[t].pt3/Norm[t1417[t]])^2, Element[t, Reals]]

Plot[dp2[t], {t,0,1}]

Plot[dp2[t], {t,0,2}]

t1421[t_] = D[dp2[t], t]

Plot[t1421[t], {t,0,2}]

Solve[t1421[t] == 0, t]

same thing w/ vars now

pt1 = {x1, y1, z1}

pt2 = {x2, y2, z2}

t1417[t_] = pt1 + t*(pt2-pt1);

pt3 = {x3, y3, z3};

conds = {Element[{t, x1, y1, z1, x2, y2, z2, x3, y3, z3}, Reals]}

dp2[t_] = Simplify[(t1417[t].pt3/Norm[t1417[t]])^2, conds]

t1421[t_] = D[dp2[t], t]

t1430 = Solve[t1421[t] == 0, t];

t1431 = t1430[[2,1,2]]

t1431 /. {x1 -> Cos[ph1] Cos[th1], y1 -> Cos[ph1] Sin[th1], z1 -> Sin[ph1],
          x2 -> Cos[ph2] Cos[th2], y2 -> Cos[ph2] Sin[th2], z2 -> Sin[ph2],
          x3 -> Cos[ph3] Cos[th3], y3 -> Cos[ph3] Sin[th3], z3 -> Sin[ph3]
}



t1431 /. z1^2 -> 1-x1^2-y1^2

t1431 /. {z1^2 -> 1-x1^2-y1^2, z2^2 -> 1-x2^2-y2^2, z3^2 -> 1-x3^2-y3^2}

now lets find all points w/ a given distance

Solve[dp2[t] < v, t]

dp2[t1431]

Solve[dp2[x] <= v, {x3, y3, z3}]

this time using sins/etc

pt1 = sph2xyz[{th1, ph1, 1}]

pt2 = sph2xyz[{th2, ph2, 1}]

t1417[t_] = pt1 + t*(pt2-pt1);

pt3 = sph2xyz[{th3, ph3, 1}];

conds = {Element[{t, th1, ph1, th2, ph2, th3, ph3}, Reals]}

dp2[t_] = Simplify[(t1417[t].pt3/Norm[t1417[t]])^2, conds]

t1421[t_] = Simplify[D[dp2[t], t], conds]

t1430 = Solve[t1421[t] == 0, t, Reals];

t1431 = t1430[[2,1,2]]

t1431 /. z1^2 -> 1-x1^2-y1^2

t1431 /. {z1^2 -> 1-x1^2-y1^2, z2^2 -> 1-x2^2-y2^2, z3^2 -> 1-x3^2-y3^2}

distance from a point less than equal to something p3 is on sphere

conds = Element[{x1, y1, z1, x3, y3, z3}, Reals];

dp2 = (({x1, y1, z1}.{x3, y3, z3})/Norm[{x1,y1,z1}])^2

Solve[dp2 == x, {x3, y3, z3}]

t1500=Simplify[Solve[{dp2 == x, x3^2 + y3^2 + z3^2 == 1}, {x3, y3, z3}],conds]

if we assume x1, y1, z1 also on sphere

dp2 = {x1, y1, z1}.{x3, y3, z3}

Solve[dp2 == x, {x3, y3, z3}]


t1507=Simplify[Solve[{dp2 == x, x3^2 + y3^2 + z3^2 ==1}, {x3, y3, z3}],conds]

<question>

Subject: Buffering world polygons and using RegionPlot/ContourPlot works poorly

I wanted to show how clever I was by solving https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth using Mathematica, but it turns out I'm not that clever after all and thus asking for help.

**Goal**: Find the area of water that is less than n km from land

I think my approach is correct, but that I need to tweak some default values, possibly those relating to precision and accuracy.

<pre><code>

(* load the polygons that make up the World, ignoring Antarctica for now *)

worldpoly0 = Entity["Country", "World"]["Polygon"]; 

(* worldpoly0 has head "Polygon" and worldpoly[[1]] has head
"GeoPosition"; to get to the actual lists of points, we need
worldpoly[[1,1]] *)

worldpoly = worldpoly0[[1,1]];

(* the Earth's average radius in km, since we'll need it later *)

earthRadius = 6371;

(* the list of points for each polygon is in {latitude, longitude}
format; poly2D23D converts such a list to 3 dimensions and joins the
last point to the first point to close the now 3-dimensional list of points
*)

sph2xyz[th_, ph_, r_] = {r*Cos[ph]*Cos[th], r*Cos[ph]*Sin[th], r*Sin[ph]}
 
sph2xyz[l_] := sph2xyz @@ l

poly2D23D[list_] := Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&, 
 Append[list, list[[1]]]];

worldlines3d = Table[Line[poly2D23D[i]], {i, worldpoly}];

(* 

The line above applies poly2D23D to every point in worldpoly, one
polygon at a time, creating a list of multilines.

Note: even though the endpoints of the multilines are on the sphere,
the lines connecting these points are not. These are standard
Euclidean lines (not geodesics) and are below the Earth's surface. I
will show later below that the error introduced here is small.

There are at least two other ways to do this:

worldlines3d = Line[Table[poly2D23D[i], {i, worldpoly}]];

This makes worldlines3d a *single* Line object (that contains several
multilines). However, when I use RegionDistance[] with the above, it
takes forever to create the function and again forever to evaluate it
at any point.

Another approach:

worldlines3d = Polygon[Table[poly2D23D[i], {i, worldpoly}]];

This creates polygons instead of multilines, but the "below the
Earth's surface" problem becomes much more serious. Since only the
polygon's vertices are on the sphere, the polygon's themselves can get
quite a bit below the Earth's surface.

*)

(* to make sure everything looks OK, lets plot the results in 3D *)

worldlines3dg = Graphics3D[worldlines3d];

</code></pre>

[[image41.gif]]

It looks a little ugly because it's transparent, but otherwise accurate.

<pre><code>

(* worldlines3d is itself not a region, but each of its individual
elements are; we now create RegionDistance functions for each element
*)

distFunctions = Table[RegionDistance[i], {i, worldlines3d}];

(* the distance from a point to the coast is the minimum of the
distFunctions above; this seems like a very inefficient way to compute
coastal distance, but every other method I tried is even slower *)

coastDistance[p_] := Min[Table[f[p], {f, distFunctions}]];

(* how far below the surface are these lines? let's find how close the
region is to the origin; since we are treating the Earth as a unit
sphere, we multiply by the Earth's average radius *)

coastDistance[{0,0,0}]*earthRadius

(* 

The answer is 6370.76, showing that the lines remain within 0.24km or
240 meters of the Earth's surface, so the resulting error should be
negligible.

Note the distances we measure here are straight line Euclidean
distances, since RegionDistance[] doesn't compute
geodesics. Fortunately, there's a formula to convert between straight
line and geodesic distances by computing the angle formed by the
straight line. The reverse formula is also useful:

*)

lineDist2geoDist[x_] = 2*ArcSin[x/2]*earthRadius;

geoDist2LineDist[x_] = 2*Sin[x/earthRadius/2];

(* the coordinates Mathematica gives for world polygons are in {lat,
lon} format; this converts them to {lon, lat}, which I will be using
for plotting *)

(* this probably the worst possible way to reverse coords *)

rectifyCoords[list_] := Transpose[Reverse[Transpose[list]]];

worldpolyRectified = Table[rectifyCoords[i], {i, worldpoly}];

(* now, let's plot coastDistance on a world map with polygons to see
if it's reasonable; the large image size renders faster, but I shrunk
it down using ImageMagick to upload here *)

plot2 = ContourPlot[
 lineDist2geoDist[coastDistance[sph2xyz[lon*Degree, lat*Degree, 1]]],
 {lon, -180, 180}, {lat, -90, 90}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

Show[{plot2, Graphics[Polygon[worldpolyRectified]]}]

lineDist2geoDist[coastDistance[sph2xyz[0, 0, 1]]]

TODO: note inside the polygons too

plot3 = ContourPlot[
 lineDist2geoDist[coastDistance[sph2xyz[lon*Degree, lat*Degree, 1]]],
 {lon, -81, -80}, {lat, 25, 26}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

Show[{plot3, Graphics[Polygon[worldpolyRectified]]}]

plot3 = ContourPlot[
 lineDist2geoDist[coastDistance[sph2xyz[lon*Degree, lat*Degree, 1]]],
 {lon, -98.4375, -95.625}, {lat, 27.059, 29.535}, 
 AspectRatio -> 1/2, ColorFunction -> Hue, Contours -> 64, 
 PlotLegends -> True, ImageSize -> {8192, 4096}]

Show[{plot3, Graphics[Polygon[worldpolyRectified]]}]


</code></pre>


keyword: gis


tried many, polys instead of lines, one mujltiline at time even one line at a time, mention this file

TODO: Sticky poly problem

approach w/ for a given lat...

conds = Element[{lon1, lat1, lon2, lat2, d}, Reals];

t1612 = Simplify[
 Solve[sph2xyz[{lon1, lat1, 1}].sph2xyz[{lon2, lat2, 1}] == d, lon2], 
 conds];

t1612[[1,1,2]] /. C[1] -> 0
t1612[[2,1,2]] /. C[1] -> 0


t1612[[1]] /. C[1] -> 0

t1612[[1,1,2]] /. C[1] -> 0

t1621[lon1_, lat1_, lat2_, d_] = Simplify[t1612[[1,1,2]] /. C[1] -> 0, conds]

t1621[-106.5*Degree, 35*Degree, 40*Degree, 0.1]



t1614 = Solve[sph2xyz[{-106, 35, 1}].sph2xyz[{lon2, lat2, 1}] == 0.1, lon2]

(* the list of longitudes at a given latitude whose geodesic distance from lat, lon is d in km *)

(* TODO: Earth circum not exacly 40K km *)

lonRange1[lat_, lon_, lat2_, d_] = 
       Simplify[Solve[sph2xyz[{lon*Degree, lat*Degree, 1}].
                      sph2xyz[{lon2*Degree, lat2*Degree, 1}] == 
             Cos[d*2*Pi/40000], lon2][[1,1,2]] /. C[1] -> 0, conds];


lonRange2[lat_, lon_, lat2_, d_] = 
       Simplify[Solve[sph2xyz[{lon*Degree, lat*Degree, 1}].
                      sph2xyz[{lon2*Degree, lat2*Degree, 1}] == 
             Cos[d*2*Pi/40000], lon2][[2,1,2]] /. C[1] -> 0, conds];

(* distance central longitude, which is indep on central lon *)

lonRange[lat_, lat2_, d_] = 
       Simplify[Solve[sph2xyz[{0*Degree, lat*Degree, 1}].
                      sph2xyz[{lon2*Degree, lat2*Degree, 1}] == 
             Cos[d*2*Pi/40000], lon2][[2,1,2]] /. C[1] -> 0, conds];

lonRange[lat_, lat2_, d_] = 
       Simplify[Solve[sph2xyz[{0, lat, 1}].
                      sph2xyz[{lon2, lat2, 1}] == 
             Cos[d*2*Pi/40000], lon2][[2,1,2]] /. C[1] -> 0, conds];


lonRange[lat_, lat2_, d_] = 
       Simplify[Solve[sph2xyz[{0, lat, 1}].
                      sph2xyz[{lon2, lat2, 1}] == 
             Cos[d], lon2][[2,1,2]] /. C[1] -> 0, conds];



lonRange[35, -106.5, 37, 500]


lonRange[35, -106.5, 39.5, 500]


t1646[t_] = 
 sph2xyz[lon1, lat1, 1] + t*(sph2xyz[lon2, lat2, 1]-sph2xyz[lon1, lat1, 1]);

Solve[VectorAngle[t1646[t], sph2xyz[lon3, lat3, 1]] == d]



Plot[lonRange[35, -106.5, lat, 500], {lat, 30, 40}]


Plot[lonRange2[35, lat, 500], {lat, 30.5, 39.5}]

geoDesic[lon1_, lat1_, lon2_, lat2_, t_] = 
 Take[xyz2sph[
 sph2xyz[lon1, lat1, 1] + t*(sph2xyz[lon2, lat2, 1]-sph2xyz[lon1, lat1, 1])],
 2];

geoDesic2[lon1_, lat1_, lon2_, lat2_, t_] = 
 geoDesic[lon1*Degree, lat1*Degree, lon2*Degree, lat2*Degree, t]/Degree;

ParametricPlot[geoDesic[-106.5*Degree, 35*Degree, -90*Degree,
40*Degree , t]/Degree, {t,0,1}]

t1738[t_, lat_] := Module[{pos, range}, 
 pos = geoDesic[-106.5*Degree, 35*Degree, -90*Degree, 40*Degree , t]/Degree;
 range = lonRange2[pos[[2]], lat, 500];
 If[Abs[Im[range]] > 0, Return[]];
 Return[{pos[[1]] + lonRange2[pos[[2]], lat, 500], pos[[2]]}];
];

ParametricPlot[t1738[t,lat], {t,0,1}, {lat,20,60}]

t1754 = Table[t1738[t, lat], {t, 0, 1, 0.1}, {lat, 20, 60, 1}];


t1755[lon_, lat_, lat2_] = Line[{
 {lon - lonRange2[lat, lat2, 500], lat2},
 {lon + lonRange2[lat, lat2, 500], lat2}
}];

Table[t1755[-106.5, 35, x], {x,30.5,39.5, 0.1}]

plot[lon_, lat_, d_] :=
 ParametricPlot[{x,y}, {x, lon-lonRange2[y, t, d], lon+lonRange2[y, t]},
 {t, -90, 90}];

plot[lon_, lat_, d_] :=
 ParametricPlot[{x,y}, {y, lat-0.008993169912586387879*d, 
  lat+0.008993169912586387879*d}, 
 {x, lon-lonRange2[lat, y, d], lon+lonRange2[lat, y, d]}];

t1832[lon_, lat_, d_] :=
 ParametricPlot[{x,y}, 
 {y, geoDesic2[-106.5, 35, -90, 40, t][[2]]-0.009*d, 
     geoDesic2[-106.5, 35, -90, 40, t][[2]]+0.009*d},
 {x, geoDesic2[-106.5, 35, -90, 40, t][[1]]-
      lonRange2[geoDesic2[-106.5, 35, -90, 40, t][[2]], y, d], 
     geoDesic2[-106.5, 35, -90, 40, t][[1]] + 
       lonRange2[geoDesic2[-106.5, 35, -90, 40, t][[2]], y, d]},
 {t, 0, 1}];

ParametricPlot[{x,y}, {x, 0, 10}, {y, 0, 10}]

ParametricPlot[{x+t,y+t}, {x, 0, 10}, {y, 0, 10}, {t, 0, 1}]

ParametricPlot[{x,y}, {x, 0, t}, {y, 0, t}, {t, 0, 1}]

t1843[lon1_, lat1_, lon2_, lat2_] := 
 t1843[lon1, lat1, lon2, lat2] = GeoDistance[{lat1, lon1}, {lat2, lon2}];

RegionPlot[t1843[0,0,x,y] < 500, {x,-180, 180}, {y, -90, 90}]

t1850 = Table[plot[i[[1]], i[[2]], 500], {i, allpoly[[1]]}];

Show[Graphics[Rectangle[{{-180,-90}, {180,90}}], t1850]]

Show[{Graphics[Rectangle[{-180,-90}, {180,90}]], t1850}];

t1857 = Table[rectifyCoords[i], {i, allpoly}];

Show[{Graphics[Line[t1857]], t1850}];

Show[{t1850, Graphics[Line[t1857]]}];

t1905 = Timing[Table[plot[i[[1]], i[[2]], 50], {i, allpoly[[2]]}]];

this takes.... 62+ seconds

Show[{t1905[[2]], Graphics[Line[t1857]]}];

Show[{Graphics[Line[t1857]], t1905[[2]]}];

20180806 figuring out contour plot which may work better than region plot

t1013 = ContourPlot[x+y, {x,0,1}, {y,0,1}, ColorFunction -> Hue, Contours ->
64, PlotLegends -> True]


t1015 = ContourPlot[x+y, {x,0,1}, {y,0,1}, ColorFunction -> Hue,
PlotLegends -> True, Contours -> {0.5, 1, 1.5}]

althue[h_] = Hue[h*7/8];

t1015 = ContourPlot[x+y, {x,0,1}, {y,0,1}, ColorFunction -> althue,
PlotLegends -> True, Contours -> {0.5, 1, 1.5}]


