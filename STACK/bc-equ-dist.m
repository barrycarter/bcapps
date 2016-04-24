(*

http://gis.stackexchange.com/questions/190753/using-gis-to-determine-average-land-distance-from-equator

*)

world = CountryData["World", "FullPolygon"];

worldpoly = Table[world[[1,i]], {i,1,Length[world[[1]]]}];

antpoly = Table[CountryData["Antarctica", "FullPolygon"][[1,i]], 
 {i, 1, Length[CountryData["Antarctica", "FullPolygon"][[1]]]}];

worldreal = Union[worldpoly,antpoly];

(*

commented out for testing parameters

r = Rasterize[Graphics[Polygon[worldreal]], ImageResolution -> 2500];

*)

r = Rasterize[Graphics[Polygon[worldreal]], ImageResolution -> 100];

ok, we definitely have some image padding going on

perlat = Map[Count[#,{0,0,0}]&, r[[1,1]]];

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


