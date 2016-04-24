(*

 http://gis.stackexchange.com/questions/190753/using-gis-to-determine-average-land-distance-from-equator

*)

Needs["Polytopes`"]


world = CountryData["World", "FullPolygon"];

worldpoly = Table[world[[1,i]], {i,1,Length[world[[1]]]}];

antpoly = Table[CountryData["Antarctica", "FullPolygon"][[1,i]], 
 {i, 1, Length[CountryData["Antarctica", "FullPolygon"][[1]]]}];

worldreal = Union[worldpoly,antpoly];

TODO: this is temp to figure out ant prob!!!

worldreal = antpoly

r = Rasterize[Graphics[Polygon[worldreal]], ImageResolution -> 200];

arr = r[[1,1]];

arr2=Table[Mean[arr[[i,j]]]/255,{i, 1, Length[arr]},{j, 1, Length[arr[[i]]]}];

perlat = Map[Count[#,1]&, arr2]

ListPlot[perlat]

perllat[[22]] is only 40



Count[arr2[[5]], 1]

Map[Mean[#]&, arr, 2]

r[[1,1]] = 503, 1000



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


