(* Open the image, and create a boundary image *)

image = Import["world-big-ne.png"];

boundary = MorphologicalPerimeter[image];

(* use the image size to determine latitude/longitude of each pixel *)

imageData = ImageData[image];

{height, width} = Take[Dimensions[imageData, 2]]

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

t0517 = VoronoiMesh[litPixels, ImageSize -> {1600,900}]

MeshCells[t0517, 0][[5]]

MeshCoordinates[t0517][[5]]



litPixels3D = Table[pts[[i[[1]],i[[2]]]], {i, litPixels}];

regionDistance = RegionDistance[Point[litPixels3D]];

(* apply regiondistance function to all points *)

distances = Map[regionDistance, pts];

(* convert linear distances to geodesic distances in km *)

lin2geo[d_] = 6371.009*2*ArcSin[d/2];

distancesGeo = Map[lin2geo, distances];

(* sign distances by determining if pixel was "lit" in original image *)

distancesGeoSigned = Table[
 distancesGeo[[i,j]]*If[imageData[[i,j]] == 1, -1, 1],
 {i, 1, height}, {j, 1, width}];

maxDist = Max[distancesGeoSigned]

minDist = Min[distancesGeoSigned]

normalized = (distancesGeoSigned-minDist)/(maxDist-minDist);

t1145 = Image[normalized];

Export["image.tiff", t1145, "TIFF"];

(* does voronoi help? *)

t1129 = VoronoiMesh[Point[litPixels3D]];                               

(* save as TIF? *)

t1135 = Image[distancesGeoSigned];

Export["image.tiff", t1135, "TIFF"];

(* data was not preserved, everything became 1s [or 0s?] *)

t1140 = Import["image.tiff", "TIFF"];

ListContourPlot[distancesGeoSigned]
