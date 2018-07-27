https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

world = CountryData["World", "FullPolygon"];

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








