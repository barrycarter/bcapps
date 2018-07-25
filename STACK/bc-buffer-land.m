https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

world = CountryData["World", "FullPolygon"];

ListPlot[world[[1,1,5]]]


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

a1 = << /home/user/20180724/land-polygons-complete-4326/land_polygons.m;








