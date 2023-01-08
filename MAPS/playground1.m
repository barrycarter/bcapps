(* must be zip mounted *)

sf = Import["/mnt/zip/gadm41_USA_shp.zip/gadm41_USA_0.shp", "Data"];

geom = "Geometry" /. sf;

geom2 = GeoPosition[geom];

(* below fails *)

Short[GeoDistance[geom, {0,0}], 20]

(* also fails *)

Short[GeoDistance[geom[[1]], {0,0}], 20]

(* works but not useful *)

Short[GeoDistance[geom[[1,1,1,1]], {0,0}], 20]                         

(* returns {1,1, 8439} *)

Dimensions[geom]

(* returns {8439} *)

Dimensions[geom[[1,1]]]                                                

t1637 = geom[[1,1,1]] /. GeoPosition[x_] -> x                                  

pos1 = GeoPosition[{{0,0}, {1,1}}]

pos2 = GeoPosition[{{2,2}, {3,3}}]

list1 = Table[GeoPosition[{i,i}], {i, 1, 10}]

list2 = Table[GeoPosition[{-i,-i}], {i, 1, 10}]

t1651= GeoGroup[list1]

t1652= GeoGroup[list2]

GeoDistance[t1651, t1652]

(* above yields 313.799 kilometers *)

t1653 = GeoGroup[geom];

Short[GeoDistance[t1653, {0,0}]]

t1655 = GeoGroup[geom[[1,1]]];                                         

Short[GeoDistance[t1655, {0,0}]]

(* below works *)

GeoDistance[GeoGroup[Map[GeoPosition, geom[[1,1,1,1,1]]]], {0,0}]    

Short[geom /. GeoPosition[x_] -> Map[GeoPosition, x], 20]

t1706 = GeoGroup[geom /. GeoPosition[x_] -> Map[GeoPosition, x]];

t1710 = geom[[1,1]] /. Polygon[GeoPosition[x_]] -> Map[GeoPosition, x];

t1714 = geom[[1,1]] /. Polygon[GeoPosition[x_]] -> x;

t1715 = Map[GeoPosition, t1714];

t1716 = Flatten[geom[[1,1]] /. Polygon[GeoPosition[x_]] -> x];

t1717 = Map[GeoPosition, Partition[t1716, 2]];

t1720 = GeoGroup[t1717];

t1724 = Table[RandomReal[1,3], {i, 1, 1000}]

t1726 = Table[RandomReal[1,3], {i, 1, 1000000}];

t1727 = RegionDistance[Point[t1726]];

t1727 = Partition[t1716, 2];

t1279[{lat_, lng_}] = sph2xyz[lng*Degree, lat*Degree, 1]

t1731 = Map[t1279, t1727];

t1732 = RegionDistance[Point[t1731]]

t1736[list_] := Map[t1279, list]

t1740[x_] := Polygon[Map[t1279, x[[1,1]]]]

t1741 = Map[t1740, geom[[1,1]]];

(* restart on 2023-01-07 to do this short and quick, with smaller shapefile *)

sf = Import["/mnt/zip/gadm41_FRA_shp.zip/gadm41_FRA_0.shp", "Data"];

geom = "Geometry" /. sf;

(* we now remove the geoposition stuff, leaving these as polygons *)

geom2 = geom[[1,1]] /. GeoPosition[x_] -> x;

(* we could Graphics[geom2] to see France *)

(* just the points *)

geom4 = Partition[Flatten[
geom2 /. Line[x_] -> x /. FilledCurve[x_] -> x /. Polygon[x_] -> x
],2];

geom5 = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, geom4];

df = RegionDistance[Point[geom5]];

ContourPlot[df[sph2xyz[lng*Degree, lat*Degree, 1]], {lng, -180, 180},
 {lat, -90, 90}]

ContourPlot[df[sph2xyz[lng*Degree, lat*Degree, 1]], {lng, -180, 180},
 {lat, -90, 90}, ColorFunction -> Hue, Contours -> 64]



geom4 = Partition[Flatten[geom2 /. 
 {Polygon[x_] -> x, Line[x_] -> x, FilledCurve[x_] -> x, Line[x_] -> x,
 Line[x_] -> x}], 2];

(* 3d polygons now *)

geom3 = geom2[[1,1]] /. {lat_, lng_} -> sph2xyz[lng*Degree, lat*Degree, 1];


(* same thing w USA *)

sf = Import["/mnt/zip/gadm41_USA_shp.zip/gadm41_USA_0.shp", "Data"];

geom = "Geometry" /. sf;

geom4 = Partition[Flatten[
geom[[1,1]] /. GeoPosition[x_] -> x /. Line[x_] -> x /. FilledCurve[x_] -> x 
 /. Polygon[x_] -> x],2];

(* just as a test *)

Graphics[Point[geom4]]

(* test worked *)

geom5 = Map[sph2xyz[#[[2]]*Degree, #[[1]]*Degree, 1] &, geom4];

(* more test *)

Graphics3D[Point[geom5]]

(* more test slow, but worked *)

df = RegionDistance[Point[geom5]];

ContourPlot[df[sph2xyz[lng*Degree, lat*Degree, 1]], {lng, -180, 180},
 {lat, -90, 90}, ColorFunction -> Hue, Contours -> 64]

(* note that "Graphics[geom]" does work *)

t1503 = Rasterize[Graphics[geom]];

t1511 = SignedRegionDistance[Point[geom5]];

ContourPlot[t1511[sph2xyz[lng*Degree, lat*Degree, 1]], {lng, -180, 180},
 {lat, -90, 90}, ColorFunction -> Hue, Contours -> 64]

(* this is true: RegionQ[Point[geom[[1]]]] *)


(* but not a constant region, so this fails *)

t1626 = RegionDistance[Point[geom[[1]]]]



