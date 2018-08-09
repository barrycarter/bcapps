(*

Solves https://mathematica.stackexchange.com/questions/178316/project-map-to-a-particular-shape in some sense 

*)

<formulas>

(* convert degree longitude/latitude to 3D point *)

lonLatDeg2XYZ[lon_, lat_] = sph2xyz[lon*Degree, lat*Degree, 1];

lonLatDeg2XYZ[l_] := lonLatDeg2XYZ @@ l;

poly2D23D[list_] := Map[lonLatDeg2XYZ, Append[list, list[[1]]]];

(* because Mathematica's polygons are "backwards" *)

rectifyCoords[list_] := Transpose[Reverse[Transpose[list]]];

showit2 := Module[{file}, file = StringJoin["/tmp/math", 
       ToString[RunThrough["date +%Y%m%d%H%M%S", ""]], ".gif"]; 
     Export[file, %, ImageSize -> {8192, 4096}]; 
     Run[StringJoin["display -geometry 800x600 -update 1 ", file, "&"]]; 
    Return[file];];

(* main polygons only *)

usa = Entity["Country", "UnitedStates"]["Polygon"][[1,1,1]];
france = Entity["Country", "France"]["Polygon"][[1,1,1]];

(* in 2D, lon/lat form *)

usa2d = rectifyCoords[usa];
france2d = ectifyCoords[france];

(* in 3D *)

usa3d = poly2D23D[usa];
france3d = poly2D23D[france];

(* region distance functions (from coast) *)

usard = RegionDistance[Line[usa3d]];
francerd = RegionDistance[Line[france3d]];

(* region distance as lon/lat *)

usard2d[lon_, lat_] := usard[lonLatDeg2XYZ[lon, lat]];
francerd2d[lon_, lat_] := francerd[lonLatDeg2XYZ[lon, lat]];

</formulas>

t1249 = RegionBounds[Line[usa2d]];

t2302 = ContourPlot[usard2d[lon, lat], {lon, t1249[[1,1]], t1249[[1,2]]}, 
{lat, t1249[[2,1]], t1249[[2,2]]}, AspectRatio -> 1/2,
ColorFunction -> Hue, Contours -> 64, ImageSize -> {8192, 4096}];

TODO: note imprecision because using lines (sag below globe)

(* TODO: largest cities to make things more interesting *)

usacities = Entity["Country", "UnitedStates"]["LargestCities"];

usacities2 = Table[{i["Name"], 
 i["Longitude"]/Quantity[1,"degree"], i["Latitude"]/Quantity[1,"degree"]}, 
{i, usacities}];

Maximize[usa4[sph2xyz[lon*Degree, lat*Degree, 1]],
Element[sph2xyz[lon, lat, 1]], RegionMember[usa3, sph2xyz[lon*Degree,
lat*Degree, 1]]]



https://www.wolfram.com/mathematica/new-in-10/entity-based-geocomputation/find-the-most-interior-point-in-the-united-states.html is stupid






Table[rectifyCoords[i], {i, usa[[1,1]]}]

t2252 = Table[rectifyCoords[i], {i, usa[[1,1]]}];

Graphics[Line[t2252]]
Graphics[Line[t2252[[2]]]]


TODO: note similarity to bc-buffer-land.m problem

TODO: note my map different from OP's
