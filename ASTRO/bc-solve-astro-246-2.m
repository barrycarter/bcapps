(* another attempt to solve
http://astronomy.stackexchange.com/questions/246/do-any-known-exoplanetary-solar-bodies-have-annular-eclipses-similar-to-earth
but allowing for satellite/satellite eclipses and more *)

(* determine the min and max distances between two astronomical
objects, allowing for a fair number or variations *)

distance[a1_,a2_] := Module[{center,alt},

 (* TODO: add check for missing data *)

 (* if I orbit the object or vice versa, this is fairly easy *)
 If[AstronomicalData[a1,"OrbitCenter"] == a2,
  Return[{AstronomicalData[a1,"Periapsis"],AstronomicalData[a1,"Apoapsis"]}]];
 If[AstronomicalData[a2,"OrbitCenter"] == a1,
  Return[{AstronomicalData[a2,"Periapsis"],AstronomicalData[a2,"Apoapsis"]}]];

 (* two satellites of same planet, assumes nonoverlapping orbits *)
 (* TODO: this is right for max, wrong for min *)
 If[AstronomicalData[a1,"OrbitCenter"] == AstronomicalData[a2,"OrbitCenter"],
  Return[{Sort[
  {Abs[AstronomicalData[a1,"Periapsis"]-AstronomicalData[a2,"Apoapsis"]],
  Abs[AstronomicalData[a1,"Apoapsis"]-AstronomicalData[a2,"Periapsis"]]}][[1]],
   Abs[AstronomicalData[a1,"Apoapsis"]+AstronomicalData[a2,"Apoapsis"]]}]];

 (* TODO: satellite of planet distance from Sun *)
 If[a1 == "Sun", alt=a2];
 If[a2 == "Sun", alt=a1];
 center = AstronomicalData[alt,"OrbitCenter"];
 Return[{
  AstronomicalData[center,"Periapsis"]-AstronomicalData[alt,"Apoapsis"],
  AstronomicalData[center,"Apoapsis"]+AstronomicalData[alt,"Apoapsis"]
 }];


 (* intentionally ignoring satellite distance for two different planets *)

]

(* minimum and maximum angular diameter of a2 as viewed from a1, not
commutatitve *)

angdiam[a1_,a2_] := Module[{dist},
 dist = distance[a1,a2];
 diam = AstronomicalData[a2,"Diameter"];
 Return[Sort[{2*ArcTan[diam/2/dist[[1]]],2*ArcTan[diam/2/dist[[2]]]}]];
]

