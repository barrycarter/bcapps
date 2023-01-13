(*

Tips and tricks:

  - Import as "All", not "Data", not "SHP", and not default















*)


(* voronoi diagram for countries? *)

str = "/home/user/NOBACKUP/EARTHDATA/NATURALEARTH/10m_cultural/ne_10m_admin_0_scale_rank_minor_islands.shp";

shp = Import[str, "All"];

polygons = shp[[5, 1, 2, 2]];

(* Graphics[polygons] will show it *)

names = shp[[5, 1, 4, 2, 2, 2]];

(* as a test, USA vs Japan *)

posUSA = Position[names, "USA"]
posJPN = Position[names, "JPN"]

polyUSA = Part[polygons, Flatten[posUSA]];
polyJPN = Part[polygons, Flatten[posJPN]];

factor = 4;

imagesize = {360*factor, 180*factor};

(*

This rasterizes the graphics on a world scale and then binarizes so
that any pixel that's not totally white is considered part of the
country

Could also rasterize at "natural" size and stretch using cuboid to
find bounding box, may consider this instead

*)

dotsUSA = Rasterize[Graphics[polyUSA, PlotRange -> {{-180, 180}, {-90,
90}}, ImageSize -> imagesize]];

(* not all pixels are black or white ... *)

DeleteDuplicates[Map[Norm, dotsUSA[[1,1]], {2}]]

Graphics[Point[Position[dotsUSA[[1,1]], {255,255,255}] /. {x_, y_} -> {y,x}]]

t0624 = Length[Position[dotsUSA[[1,1]], {255,255,255}]]

(* t0624 == 63412 *)

t0625 = Length[Position[dotsUSA[[1,1]], {0,0,0}]]

(* t0625 == 892 *)

t0626 = Map[Norm, dotsUSA[[1,1]], {2}];

t0627 = Length[Flatten[t0626]]

(* t0627 == 64800 *)

t0628 = Length[Position[Flatten[t0626], 255*Sqrt[3]]]

(* t0628 == 63412 *)

t0629 = Position[dotsUSA[[1,1]], {255,255,255}];

t0630 = t0629 /. {x_, y_} -> {y, x};

(* left pixel on 39th row appears to be lit but doesnt show up *)

Graphics[{AbsolutePointSize[1], Point[t0630]}, ImageSize -> imagesize]

(* above confirms this is doing right thing *)

Binarize[Graphics[polyUSA]]


nearF = Nearest[polyUSA, polyJPN, DistanceFunction -> GeoDistance]

Nearest[{polyUSA, polyJPN}, {0,0}]

(*

works: GeoGraphics[polyUSA]                                                 

works: GeoGraphics[polyJPN]

works but yields array: 

GeoDistance[polyUSA[[1]] /. Polygon[x_] -> x /. {x_, y_} -> {y, x}, {0,0}]

yields invalid latitude: Short[GeoDistance[polyUSA[[1]] /. Polygon -> List, {0,0}], 20]        

works but yields array: GeoDistance[polyUSA[[1]] /. Polygon -> List /. {x_, y_} -> {y,x}, {0,0
}]                                                                              



*)

(*

playing with geopolygons

list1650 = { {35,-106}, {35,-105}, {36,-105}, {36,-106}, {35,-106} };

works: GeoGraphics[Polygon[Map[Reverse, list1650]]]                          

array: GeoDistance[GeoPosition[list1650], {0,0}]

works: Nearest[GeoPosition[list1650], GeoPosition[{0,0}]]

*)

(*

below fails, does not include interior

p1 = Partition[Flatten[polyUSA /. Polygon -> List], 2];

works: Short[RegionUnion[polyUSA], 20]                                       

*)

r1 = RegionUnion[polyUSA];

r2 = Rasterize[Graphics[polyUSA]];

r3 = Rasterize[Graphics[polyJPN]];

Graphics[polyJPN, PlotRange -> {{0,360}, {-90, 90}}, ImageSize -> {1800, 900}]

r4 = Rasterize[Graphics[polyJPN, PlotRange -> {{0,360}, {-90, 90}},
ImageSize -> {1800, 900}]]

(* above is bad, creates gray pixels *)

r5 = Rasterize[Graphics[polyJPN]];

(* going way simpler *)

p1 = Disk[{-106.5, 35}, 2]

p2 = Disk[{-90, 40}, 2]

ContourPlot[RegionDistance[p1, {x,y}] - RegionDistance[p2, {x,y}],
 {x, -108.5, -88}, {y, 33, 42}, ColorFunction -> Hue, Contours -> 16]

ContourPlot[Abs[RegionDistance[p1, {x,y}] - RegionDistance[p2, {x,y}]],
 {x, -108.5, -88}, {y, 33, 42}, ColorFunction -> Hue, Contours -> 16]

regreverse[x_, y_] := RegionDistance[y, x]

nf = Nearest[{p1, p2}]

nf2[x_, y_] = If[RegionDistance[p1, {x,y}] > RegionDistance[p2, {x,y}], 1, 0];

ContourPlot[nf2[x,y], {x, -108.5, -88}, {y, 33, 42}]

dotsUSA = Rasterize[Graphics[{AbsolutePointSize[1], polyUSA},
PlotRange -> {{-180, 180}, {-90, 90}}, ImageSize -> imagesize]];


(* below is True *)

Binarize[dotsUSA, 0.999] == Binarize[dotsUSA, 0.99999]

(* below is False *)

Binarize[dotsUSA, 0.999] == Binarize[dotsUSA, 0.99999999999999999]    

(* below totally works *)

t0658 = Binarize[Graphics[{AbsolutePointSize[1], polyUSA}, PlotRange
-> {{-180, 180}, {-90, 90}}, ImageSize -> imagesize],
0.9999999999999999];

(* select the positions that are black *)

dotsUSA2 = Position[ImageData[t0658], 0];

(* projectification... *)

lats = N[Table[90-180*(i-1/2)/height, {i, 1, 180*factor}]];

lngs = N[Table[360*(i-1/2)/width-180, {i, 1, 360*factor}]];

(* perhaps excessive, but precomputing sins and cosines for efficiency *)

colats = Map[Cos, lats*Degree];
colngs = Map[Cos, lngs*Degree];
silats = Map[Sin, lats*Degree];
silngs = Map[Sin, lngs*Degree];

(* convert all points to 3D [might need this for pixel based Voronoi] *)

pts = Table[{colats[[i]] * colngs[[j]], colats[[i]]*silngs[[j]], silats[[i]]},
 {i, 1, 180*factor}, {j, 1, 360*factor}];

(* and then the lit points *)

litPixels3D = Table[pts[[i[[1]],i[[2]]]], {i, dotsUSA2}];

Table[{i, Dimensions[shp[[i]]]}, {i, Length[shp]}]

Table[{i, Dimensions[shp[[5,1,i]]]}, {i, Length[shp[[5,1]]]}]

polygons = Cases[shp, _Polygon, Infinity];

names = shp[[1,4, 2, 2, 2]];

fin = Flatten[Position[names, "FIN"]];

finp = polygons[[fin]];

(* putting it all together, below code should work by itself *)

str = "/home/user/NOBACKUP/EARTHDATA/NATURALEARTH/10m_cultural/ne_10m_admin_0_scale_rank_minor_islands.shp";

shp = Import[str, "All"];

polygons = shp[[5, 1, 2, 2]];

(* Graphics[polygons] will show it *)

names = shp[[5, 1, 4, 2, 2, 2]];

factor = 1;

imagesize = {360*factor, 180*factor};

lats = N[Table[90-180*(i-1/2)/(180*factor), {i, 1, 180*factor}]];

lngs = N[Table[360*(i-1/2)/(360*factor)-180, {i, 1, 360*factor}]];

(* perhaps excessive, but precomputing sins and cosines for efficiency *)

colats = Map[Cos, lats*Degree];
colngs = Map[Cos, lngs*Degree];
silats = Map[Sin, lats*Degree];
silngs = Map[Sin, lngs*Degree];

(* convert all points to 3D [might need this for pixel based Voronoi] *)

pts = Table[{colats[[i]] * colngs[[j]], colats[[i]]*silngs[[j]], silats[[i]]},
 {i, 1, 180*factor}, {j, 1, 360*factor}];

(* conversion to 3D, using some globals *)

nation2ThreeD[x_] := Module[{pos, poly, image, lit, litPts},
 pos = Position[names, x];
 poly = Part[polygons, Flatten[pos]];
 image = Binarize[Graphics[{AbsolutePointSize[1], poly}, 
  PlotRange -> {{-180, 180}, {-90, 90}}, ImageSize -> imagesize],
0.9999999999999999];
 lit = Position[ImageData[image], 0];
 litPts = Table[pts[[ i[[1]], i[[2]] ]], {i, lit}];
 Return[Region[Point[litPts]]];
];

aus = nation2ThreeD["AUS"];

usa = nation2ThreeD["USA"];

uk = nation2ThreeD["UKR"];

ausRD = RegionDistance[aus];

usaRD = RegionDistance[usa];

ukRD = RegionDistance[uk];

(* this is for lngs lat only *)

sph2xyz[lng_, lat_] = {Cos[lng*Degree]*Cos[lat*Degree], 
 Sin[lng*Degree]*Cos[lat*Degree], Sin[lat*Degree]};

(* which country are you closest to at lng, lat? *)


closest[lng_, lat_] := Ordering[
{ausRD[sph2xyz[lng,lat]], usaRD[sph2xyz[lng, lat]], ukRD[sph2xyz[lng, lat]]}
, 1][[1]]

cp = ContourPlot[closest[lng, lat], {lng, -180, 180}, {lat, -90, 90},
 ImageSize -> {1800,900}]

gx = Graphics[shp[[7]], ImageSize -> {1800,900}]

Show[{cp, gx}]

tab = Table[closest[lng, lat], {lng, -180, 180}, {lat, -90, 90}];

