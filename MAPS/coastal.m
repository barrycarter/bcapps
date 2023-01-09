(*

Subject: 3D region best way to create signed coastal distance?

[[coastal.png]]

[[boundary.png]]

As a test, I'm trying to create a signed coastal distance map of the world (assumed perfectly spherical), using the first 1800x900 image above, which I converted to the 2nd image above using `MorphologicalPerimeter`, and was wondering if there was a more efficient approach, since I plan to use larger images to do something similar later.

My full code is below (also at https://github.com/barrycarter/bcapps/tree/master/MAPS/coastal.m), but my approach is to project coastal boundary points to 3D, create a region from them, and use the fast RegionDistance function.

Is there a better/faster way to do this? I know Mathematica has lots of Geo functions, but they seem to run slower and areharder (for me) to use unless I'm missing something.

*)

(* Open the image, and create a boundary image *)

image = Import["coastal.png"];

boundary = MorphologicalPerimeter[image];

(* use the image size to determine latitude/longitude of each pixel *)

{height, width} = Take[Dimensions[ImageData[image]], 2]

lats = N[Table[90-180*(i-1/2)/height, {i, 1, height}]];

lngs = N[Table[360*(i-1/2)/width-180, {i, 1, width}]];

(* perhaps excessive, but precomputing sins and cosines for efficiency *)

colats = Map[Cos, lats*Degree];
colngs = Map[Cos, lngs*Degree];
silats = Map[Sin, lats*Degree];
silngs = Map[Sin, lngs*Degree];

(* convert latitudes and longitudes to unit sphere *)

pts = Table[{colats[[i]] * colngs[[j]], colats[[i]]*silngs[[j]], silats[[i]]},
 {i, 1, height}, {j, 1, width}];

(* select lit boundary pixels, create 3D region function *)

litPixels = Position[ImageData[boundary], 1];

litPixels3D = Table[pts[[i[[1]],i[[2]]]], {i, litPixels}];

regionDistance = RegionDistance[Point[litPixels3D]];

(* apply regiondistance function to all points *)

distances = Map[regionDistance, pts];

(* convert linear distances to geodesic distances in km *)

lin2geo[d_] = 6371.009*2*ArcSin[d/2];

distancesGeo = Map[lin2geo, distances];

(* sign distances by determining if pixel was "lit" in original image *)

imageData = ImageData[image];

distancesGeoSigned = Table[
 distancesGeo[[i,j]]*If[imageData[[i,j]] == 1, -1, 1],
 {i, 1, height}, {j, 1, width}];
