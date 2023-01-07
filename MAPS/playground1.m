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










 




