(* another attempt to solve
http://astronomy.stackexchange.com/questions/246/do-any-known-exoplanetary-solar-bodies-have-annular-eclipses-similar-to-earth
but allowing for satellite/satellite eclipses and more *)

(* determine the min and max distances between two astronomical
objects, allowing for a fair number or variations *)

distance[a1_,a2_] := Module[{},

 (* TODO: add check for missing data *)

 (* if I orbit the object or vice versa, this is fairly easy *)
 If[AstronomicalData[a1,"OrbitCenter"] == a2,
  Return[{AstronomicalData[a2,"Periapsis"],AstronomicalData[a2,"Apoapsis"]}]];
 If[AstronomicalData[a2,"OrbitCenter"] == a1],
  Return[{AstronomicalData[a1,"Periapsis"],AstronomicalData[a1,"Apoapsis"]}]];

 (* TODO: two satellites of same planet *)

 (* TODO: assume nonoverlapping orbits *)

 (* TODO: satellite of planet distance from Sun *)

]
