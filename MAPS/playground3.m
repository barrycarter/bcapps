(* filtering of playground2.m with better functions? *)

(* the second version below does NOT require declaring all points
ahead of time and memoizes trig functions itself *)

nation2ThreeD[x_] := Module[{pos, poly, image, lit, litPts},
 cos[z_] := cos[z] = Cos[z*Degree];
 sin[z_] := sin[z] = Sin[z*Degree];
 pos = Position[names, x];
 poly = Part[polygons, Flatten[pos]];
 image = Binarize[Graphics[{AbsolutePointSize[1], poly}, 
  PlotRange -> {{-180, 180}, {-90, 90}}, ImageSize -> imagesize],
0.9999999999999999];
 lit = Position[ImageData[image], 0];
 litPts = Table[{cos[lngs[[i[[2]]]]]*cos[lats[[i[[1]]]]], 
  sin[lngs[[i[[2]]]]]*cos[lats[[i[[1]]]]], sin[lats[[i[[1]]]]]}, {i, lit}];
 Return[Region[Point[litPts]]];
];

(* using <> just so I can cut and paste w/o hitting 80 column limit *)

str = "/home/user/NOBACKUP/EARTHDATA/NATURALEARTH/10m_cultural/"<>
"ne_10m_admin_0_scale_rank_minor_islands.shp";

shp = Import[str, "All"];

polygons = shp[[5, 1, 2, 2]];

(* Graphics[polygons] will show it *)

names = shp[[5, 1, 4, 2, 2, 2]];

factor = 120/3;

imagesize = {360*factor, 180*factor};

lats = N[Table[90-180*(i-1/2)/(180*factor), {i, 1, 180*factor}]];

lngs = N[Table[360*(i-1/2)/(360*factor)-180, {i, 1, 360*factor}]];

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

