(*

Solves https://mathematica.stackexchange.com/questions/178316/project-map-to-a-particular-shape in some sense 

*)

<formulas>

poly2D23D[list_] := Map[sph2xyz[#1[[2]]*Degree, #1[[1]]*Degree, 1]&, 
 Append[list, list[[1]]]];

rectifyCoords[list_] := Transpose[Reverse[Transpose[list]]];

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

</formulas>

usa = Entity["Country", "UnitedStates"]["Polygon"];
france = Entity["Country", "France"]["Polygon"];

(* largest cities *)

usacities = Entity["Country", "UnitedStates"]["LargestCities"];

usacities2 = Table[{i["Name"], 
 i["Longitude"]/Quantity[1,"degree"], i["Latitude"]/Quantity[1,"degree"]}, 
{i, usacities}];

Table[Graphics[Point







(* the main polygons *)

usa2 = usa[[1,1,1]];
france2 = france[[1,1,1]];

(* projected to 3d *)

usa3 = poly2D23D[usa2];
france3 = poly2D23D[france2];

usa4 = RegionDistance[Line[usa3]];
france4 = RegionDistance[Line[france3]];

t2302 = ContourPlot[usa4[sph2xyz[lon*Degree, lat*Degree, 1]], {lon,
-124.733, -66.9498}, {lat, 25.1246, 49.3845}, AspectRatio -> 1/2,
ColorFunction -> Hue, Contours -> 64, ImageSize -> {8192, 4096}];





Table[rectifyCoords[i], {i, usa[[1,1]]}]

t2252 = Table[rectifyCoords[i], {i, usa[[1,1]]}];

Graphics[Line[t2252]]
Graphics[Line[t2252[[2]]]]


TODO: note similarity to bc-buffer-land.m problem

TODO: note my map different from OP's
