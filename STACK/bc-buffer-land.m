https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

world = CountryData["World", "FullPolygon"];

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

