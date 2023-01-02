(* Import the USA shapefile *)
// usa = Import["https://www.wolframcloud.com/obj/sample-data/world-data/shapefiles/usa.shp"];

polygons = CountryData["USA", "Polygons"]

(* Extract the Polygon from the shapefile *)
polygon = usa[[1, 1, 1]];

(* Define a point *)
point = GeoPosition[{40.7128, -74.0060}];

(* Calculate the distance between the point and the polygon *)
distance = GeoDistance[point, polygon]

(* Output: 5160.81 km *)

(* above fails *)

(* Get the Entity for the USA *)
usa = Entity["Country", "UnitedStates"]

(* Extract the polygons from the Entity *)
polygons = usa["Polygons"]

(* Output: {Polygon[{{-178.21, 51.65}, {-178.06, 51.46}, ...}]} *)
