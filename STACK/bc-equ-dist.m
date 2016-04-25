(* formulas start here *)

world = CountryData["World", "FullPolygon"];

worldpoly = Table[world[[1,i]], {i,1,Length[world[[1]]]}];

antpoly = Table[CountryData["Antarctica", "FullPolygon"][[1,i]], 
 {i, 1, Length[CountryData["Antarctica", "FullPolygon"][[1]]]}];

(* Mathematica won't give Antarctica polygons south of -89.9, this
fills them in *)

spole = Rectangle[{-90,-180}, {-89.9,+180}];

(* forcing Rasterize to show the north pole insures the rasterization
includes the whole world *)

npole = Point[{90,0}];

worldreal = Union[worldpoly,antpoly,{spole,npole}];

(* TODO: restore this to 2500 when doing for real! *)

r = Rasterize[Graphics[Polygon[worldreal]], ImageResolution -> 10];

worldlats = Flatten[Table[Transpose[i][[2]], {i, worldreal}]];

minlat = Min[worldlats];
maxlat = Max[worldlats];

pointsPerLat0 = Map[Count[#,{0,0,0}]&, r[[1,1]]];

(* find the first/last non-zero points in pointsPerLat and remove padding *)

nonzero = Position[pointsPerLat0, val_/;val>0];
first = Min[nonzero];
last = Max[nonzero];

(* the table above only covers minlat to maxlat, as we'd expect; we
need to add 1's for < minlat and 0's for > maxlat *)

dlat = (maxlat-minlat)/


(* this is as a percentage of total possible points per row *)

pointsPerLat = Take[pointsPerLat0/Max[pointsPerLat0], {first,last}];

(* convert row number in pointsPerLat to latitude *)

row2lat[i_] = Simplify[minlat+(i-1)/(Length[pointsPerLat]-1)*(maxlat-minlat)];

spole = Round[Solve[row2lat[i] == -90, i][[1,1,2]],1];
npole = Round[Solve[row2lat[i] == 90, i][[1,1,2]],1];

sextra = Table[{row2lat[i], 



(* table re how much of latitude intersects land, as a percentage *)

latLandPct0 = Table[{row2lat[i], pointsPerLat[[i]]/Max[pointsPerLat]}, 
 {i,1,Length[pointsPerLat]}];



(* convert to km using cosine and Earth circumference *)

latLandKM = Table[{row2lat[i], 
 40700*Cos[row2lat[i]*Degree]*pointsPerLat[[i]]/Max[pointsPerLat]},
 {i,1,Length[pointsPerLat]}];

(* for smooth graphing and because we plan to add negative and
positive latitudes later, convert to function *)

flatLandKM[lat_] = Interpolation[latLandKM, InterpolationOrder -> 1][lat];






(* formulas end here *)


(*

http://gis.stackexchange.com/questions/190753/using-gis-to-determine-average-land-distance-from-equator

**DISCLAIMER: Please see important caveats at end of message.**

The average absolute latitude of land on Earth is TODO:answer, or
about TODO:answer km from the equator.

[[image17.gif]]

The plot above shows the kilometers of land intersected by line of
latitude. Some notes:

  - The large bump on the left is Antarctica. As far north as $75 S {}^{\circ}$, Antarctica encircles 71.43% of the South Pole, a total of:

$(71.43 \%) \cos (-75 {}^{\circ}) (40700 km)\approx 7525 km$

  - If the equator were covered with land, the graph would peak at
  40700km at the equator. However, only about 21.60% of the equator is
  covered with land.

  - The actual maximum occurs at about $30 {}^{\circ} 28'$, where
  15846 km (45.17% of this 35081 km) circle is covered by land.

Of course, you're interested in the absolute latitude:

[[image18.gif]]

And since you're interested in the total accumulated land measured
from the equator, we "integrate" to get:



TODO: note Antarctica
TODO: give away data
TODO: can do better: exact polygons
TODO: more about magic value above [ie cities, near]
TODO: couldnt map sigh
TODO: note resolution

*)

acclat = Accumulate[perlat];

(* we need the table to go all the way to +90, but not -90, because
data is inaccurate for < -89.9 *)

imax = Round[Solve[row2lat[i] == 90, i][[1,1,2]],1]

tab = Table[{row2lat[i], perlat[[i]]/11999}, {i,first,imax}];

tablen = Table[{row2lat[i], 40700*Cos[row2lat[i]*Degree]*perlat[[i]]/11999}, 
 {i,first,imax}];

tabacc = Accumulate[Transpose[tablen][[2]]];

tabacc2 = Table[{row2lat[i], tabacc[[i]]/Max[tabacc]}, {i,first,imax}];

facc[x_] = Interpolation[tabacc2, InterpolationOrder -> 1][x]

faccabs[x_] = facc[x]-facc[-x];

f0[x_] = Interpolation[tab, InterpolationOrder -> 1][x]

len[x_] = Cos[x*Degree]*f0[x]*40700

xtics = Table[i, {i,-90,90,10}]
ytics = Table[i, {i,0,16000,1000}]
ytics2 = Table[i, {i,0,24000,1000}]
Plot[len[x], {x,-90,90}, Ticks -> {xtics, ytics}, PlotLabel ->
 Text[Style["Kilometers of Land vs Latitude", FontSize->25]]]
showit

lenabs[x_] = len[x] + len[-x]

ytics2 = Table[i, {i,0,24000,1000}]
Plot[lenabs[x], {x,0,90}, Ticks -> {xtics, ytics2}, PlotLabel ->
 Text[Style["Kilometers of Land vs Absolute Latitude", FontSize->25]],
 PlotRange -> { {0,90}, {0,24000}}]


acctab = Table[{row2lat[i], acclat[[i]]/Total[perlat]}, {i,first,imax}];



g[x_] = f[x] + f[-x];

h[x_] = Cos[x*Degree]*f[x]

j[x_] = Cos[x*Degree]*g[x]

f1605[x_] = Interpolation[acctab, InterpolationOrder -> 1][x];

f1609[x_] = f1605[x]-f1605[-x]

ytics3 = Table[{i, ToString[PaddedForm[i*100,{3}]]<>"%"}, {i,0,1,1/10}]
g2 = Plot[f1609[x], {x,0,90}, Ticks -> {xtics, ytics3}, PlotLabel ->
Text[Style["Percentage of Total Land Below Given Absolute Latitude",
FontSize->25]], PlotRange -> { {0,90}, {0,1}}];

g3 = Graphics[{
 RGBColor[1,0,0], Dashed,
 Line[{{0,.5},{55.5044,.5}}],
 Line[{{55.5044,0},{55.5044,.5}}]
}]

Show[g2,g3];
showit




Plot[f1605[x],{x,-90,90}]

Plot[h[x],{x,-90,90}]



(* figure out padding *)

6354, 12500 is lat/lon rastersize

Max[perlat] == 11999

502 pad pixels left/right

331 = first with non-0 (in fact, its full)
6113 = last non-0 (24 pixels)

perlat2 = Take[perlat,{331,6113}];

ListPlot[perlat2]
showit

Solve[row2lat[i] == -90, i]

328 to 6326

ListPlot[tab]
showit

tab2 = Table[{row2lat[i], Cos[row2lat[i]*Degree]*perlat[[i]]/11999*40075}, 
 {i, 328, 6326}]

tab3 = Accumulate[perlat];

tab4 = Table[{row2lat[i], tab3[[i]]/Total[perlat]}, {i, 328, 6326}];


ytics2 = Table[{i, ToString[PaddedForm[i*100,{3}]]<>"%"}, {i,0,1,1/10}]

lp = ListPlot[tab2, Ticks -> {xtics, ytics}, PlotRange -> {{-90,90},
{0, 16000}}, PlotLabel -> Text[Style["Kilometers of Land vs Latitude",
FontSize->25]]]

lp2 = ListPlot[tab4, Ticks -> {xtics, ytics2}, PlotRange -> {{-90,90},
{0, 1.1}}, PlotLabel -> Text[Style["Cumulative %age of Land vs Latitude",
FontSize->25]]]





g2 = Graphics[{
 Rectangle[{-90, 0}, {90, 18000}],
 Text[Style["Kilometers of Land vs Latitude", FontSize->25], {0,18000}]
}]

Show[{g2,lp}, AspectRatio -> Automatic]
showit


Show[{lp,g2}, PlotRange -> {{-90,90}, {-1000,16000}}]
showit

Show[ListPlot[tab2], Ticks -> {xtics, ytics}, 
PlotLabel -> "Kilometers of Land vs Latitude"]
showit

TODO: about 3.3 km per tick



TODO: Max[perlat] might be bad below... but works better because r
overmaps the longitude

tab = Table[{180/Length[perlat]*i-90, 
 perlat[[i]]/Max[perlat]}, {i, 1, Length[perlat]}];

ListPlot[tab]
showit

tab; first 331 entries are empty, as are last 241 (suggesting I've got
it flipped?)

if above is right {{83.1728, 0.00200017} is max and 
-76.5439, 0.993749 is low end (something's wrong)

ImageSize -> {360., 182.995}
PlotRange -> {{0, 360.}, {0, 182.995}}

-89.9 = mathematica cutoff
83.6096 = max (but that might just be no land beyond)

if elt 331 = -89.9 and 6113 is 83.6096 we have roughly

tr[i_] = Simplify[-89.9+(i-331)/(6113-331)*(83.6096+89.9)]

173.51 = range mapped

Export["/tmp/test.png", r, ImageSize->{12500/5, 6354/5}]

/tmp/test.png: PNG image, 2500 x 1271, 8-bit/color RGB, non-interlaced

on this image:

left 49 pixels are blank
pxiels 2450+ are blank (x wise)
top 47 pixels are blank
pixels 1205 and below are blank



TODO: assuming spherical

arr = r[[1,1]];


arr2=Table[Mean[arr[[i,j]]],{i, 1, Length[arr]},{j, 1, Length[arr[[i]]]}];

arr2=Table[Mean[arr[[i,j]]]/255,{i, 1, Length[arr]},{j, 1, Length[arr[[i]]]}];




ListPlot[perlat]

perllat[[22]] is only 40



Count[arr2[[5]], 1]

Map[Mean[#]&, arr, 2]

r[[1,1]] = 503, 1000

TODO: disclaim not great answer + why


Table[Mean[r[[1,1,i,j]], {i, 1, Length[r[[1,1]]]



r = Rasterize[Graphics[Polygon[worldreal[[7]]]]]



r[[1,1,1]] is 43 elts, each elt is 100 and contains 3 "color" points

TODO: caveats http://mathematica.stackexchange.com/questions/10229/countrydata-and-the-areas-of-the-world



Integrate[1, Element[x, CountryData["France", "SchematicPolygon"]]]

fails with:

Region`RegionProperty::nmet: -- Message text not found -- (RegionDimension)

Integrate[1, Element[x,CountryData["Monaco", "SchematicPolygon"]]]     

above works!

(order is lon/lat)

Integrate[Cos[y*Degree], 
 Element[{x,y}, CountryData["Monaco", "SchematicPolygon"]]]

0.000501763 is area when corrected for radians
0.000673392 is answer
1.95 is area

2895.79 is quotient
3886.3 is corrected quotient


mon = Polygon[{{{7.45, 43.75}, {7.38333, 43.7167}, {7.38333, 43.7333},
{7.43333, 43.75}}}]

bhu = Polygon[{{{88.9167, 27.3167}, {90., 28.3167}, {91.65, 27.7667}, 
{88.9167, 27.3167}}}]

bhu2 = Polygon[{{{88.9167, 27.3167}, {90., 28.3167}, {91.65, 27.7667}}}]

monaco works, bhutan fails

Integrate[1, Element[x,mon]]
Integrate[1, Element[x,bhu]]
Integrate[1, Element[x,bhu2]]

polygonArea = 
 Compile[{{v, _Real, 2}}, 
   Block[{x, y},
    {x, y} = Transpose[v]; 
    Abs[x.RotateLeft[y] - RotateLeft[x].y]/2
   ]
 ]

polyarea = Abs@Tr[Det /@ Partition[#, 2, 1, 1]]/2 &;

polyarea[mon]

testpoint2[poly_, pt_] := Graphics`Mesh`InPolygonQ[poly, pt]

testpoint2[world, {4,5}]

inPoly2[poly_, pt_] := Module[{c, nvert,i,j},
   nvert = Length[poly];
   c = False;
   For[i = 1, i <= nvert, i++,
    If[i != 1, j = i - 1, j = nvert];
    If[(
      ((poly[[i, 2]] > pt[[2]]) != (poly[[j, 2]] > pt[[2]])) && (pt[[
      1]] < (poly[[j, 1]] - 
         poly[[i, 1]])*(pt[[2]] - poly[[i, 2]])/(poly[[j, 2]] - 
          poly[[i, 2]]) + poly[[i, 1]])), c = ! c];
    ];
   c
   ];

pnPoly[{testx_, testy_}, pts_List] := Xor @@ ((
      Xor[#[[1, 2]] > testy, #[[2, 2]] > testy] && 
       ((testx - #[[2, 1]]) < (#[[1, 1]] - #[[2, 1]]) (testy - #[[2, 2]])/(#[[1, 2]] - #[[2, 2]]))
      ) & /@ Partition[pts, 2, 1, {2, 2}])


